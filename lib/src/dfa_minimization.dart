import 'package:automata_simulator/automata_simulator.dart';
import 'package:automata_simulator/src/utils.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';

typedef StateEquivalent<T> = EquatableSet<FAState<T>>;
typedef EquivalentClass<T> = EquatableSet<StateEquivalent<T>>;

Either<String, DFA<String>> minimizeDFA<T>(DFA<T> dfa) {
  final initialEquivalent = getInitialEquivalent(dfa);
  final equivalentClasses = computeEquivalentClasses(dfa, [initialEquivalent]);

  final mStates = equivalentClasses.last;

  final mInitialState = findStateInMDFA(dfa.initialState, mStates);

  final mAcceptingStates = findAcceptingStatesInMDFA(dfa.acceptingStates, mStates);

  final mTransitionEntries = buildMDFATransitions(dfa, mStates);

  return DFA.createDFA(
    convertToStates(mStates),
    dfa.alphabet,
    DFATransitionFn<String>.fromEntries(mTransitionEntries.map((transition) {
      return MapEntry((convertToState(transition.key.$1), transition.key.$2), convertToState(transition.value));
    })),
    convertToState(mInitialState),
    convertToStates(mAcceptingStates),
  );
}

EquivalentClass<T> getInitialEquivalent<T>(DFA<T> dfa) {
  final nonAcceptingStates = dfa.states.difference(dfa.acceptingStates);
  final acceptingStates = dfa.acceptingStates;

  return EquatableSet({EquatableSet(nonAcceptingStates), EquatableSet(acceptingStates)});
}

List<EquivalentClass<T>> computeEquivalentClasses<T>(DFA<T> dfa, List<EquivalentClass<T>> equivalentClasses) {
  final previousEquivalentClass = equivalentClasses.last;
  final currentEquivalentClass = calculateEquivalentClass(dfa, previousEquivalentClass);

  if (previousEquivalentClass == currentEquivalentClass) return equivalentClasses;

  return computeEquivalentClasses(dfa, [...equivalentClasses, currentEquivalentClass]);
}

EquivalentClass<T> calculateEquivalentClass<T>(DFA<T> dfa, EquivalentClass<T> previousEquivalentClass) {
  final groupTable = buildEquivalentTable(dfa, previousEquivalentClass);
  final groupsNumbers = extractGroupNumberSets(groupTable);
  final equivalentSet = deriveEquivalentSet(dfa, groupTable, groupsNumbers);

  return equivalentSet;
}

EquivalentClass<T> deriveEquivalentSet<T>(
  DFA<T> dfa,
  Map<FAState<T>, Map<String, int>> table,
  EquatableSet<EquatableList<int>> groups,
) {
  final EquivalentClass<T> initialValue = EquatableSet({});

  final equivalentSet = groups.fold(initialValue, (res, group) {
    final statesInTheSameGroup = table.entries.where((entry) {
      return group == EquatableList(entry.value.values.toList());
    }).map((e) => e.key);

    return EquatableSet({
      ...res,
      EquatableSet(statesInTheSameGroup.where(dfa.acceptingStates.contains).toSet()),
      EquatableSet(statesInTheSameGroup.whereNot(dfa.acceptingStates.contains).toSet())
    }.where((e) => e.isNotEmpty).toSet());
  });

  final sortedEquivalentSet = equivalentSet.sorted((a, b) => b.length - a.length).toSet();

  return EquatableSet(sortedEquivalentSet);
}

Map<FAState<T>, Map<String, int>> buildEquivalentTable<T>(DFA<T> dfa, EquivalentClass<T> equivalentClass) {
  final table = dfa.states.map((state) {
    final symbolWithGroupNumberEntries = dfa.alphabet.map((symbol) {
      final nextState = dfa.transitionFunction(state, symbol).getOrElse(() => throw Exception('Unexpected Error.'));

      final (int groupNumber, _) = equivalentClass.indexed.singleWhere((indexedEquivalentState) {
        final (_, equivalentState) = indexedEquivalentState;

        return equivalentState.contains(nextState);
      });

      return MapEntry(symbol, groupNumber);
    });

    return MapEntry(state, Map.fromEntries(symbolWithGroupNumberEntries));
  });

  return Map.fromEntries(table);
}

EquatableSet<EquatableList<int>> extractGroupNumberSets<T>(Map<FAState<T>, Map<String, int>> table) {
  final EquatableSet<EquatableList<int>> initialValue = EquatableSet({});
  return table.entries.fold(initialValue, (sets, entry) {
    final values = EquatableList(entry.value.values.toList());

    return EquatableSet({...sets, values});
  });
}

StateEquivalent<T> findStateInMDFA<T>(FAState<T> state, EquivalentClass<T> equivalentClass) {
  return equivalentClass.singleWhere((equivalentState) {
    return equivalentState.any((e) => e == state);
  });
}

Set<StateEquivalent<T>> findAcceptingStatesInMDFA<T>(
  Set<FAState<T>> acceptingStates,
  EquivalentClass<T> equivalentClass,
) {
  return equivalentClass.where((equivalentState) {
    return equivalentState.any(acceptingStates.contains);
  }).toSet();
}

Iterable<MapEntry<(EquatableSet<FAState<T>>, String), EquatableSet<FAState<T>>>> buildMDFATransitions<T>(
  DFA<T> dfa,
  EquivalentClass<T> equivalentClass,
) {
  return equivalentClass.flatMap((state) {
    return dfa.alphabet.map((symbol) {
      final nextState =
          dfa.transitionFunction(state.first, symbol).getOrElse(() => throw Exception('Unexpected Error.'));
      final mNextState = equivalentClass.singleWhere((state) => state.contains(nextState));

      return MapEntry((state, symbol), mNextState);
    });
  });
}

Set<FAState<String>> convertToStates<T>(Iterable<StateEquivalent<T>> states) => states.map(convertToState).toSet();

FAState<String> convertToState<T>(StateEquivalent<T> states) {
  final String name = states.map((element) => element.name).join('_');

  return FAState(name);
}
