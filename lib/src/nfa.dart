import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';

import 'computation_tree.dart';
import 'dfa.dart';
import 'fa_state.dart';
import 'fa_validator.dart';
import 'machine_configuration.dart';
import 'utils.dart';

typedef FAStateSet<T> = EquatableSet<FAState<T>>;
typedef NFATransitionFn<T> = Map<(FAState<T>, Option<String>), Set<FAState<T>>>;

class NFA<StateType> {
  NFA._(this.states, this.alphabet, this.transitions, this.initialState, this.acceptingStates);

  static Either<String, NFA<StateType>> createNFA<StateType>(
    Set<FAState<StateType>> states,
    Set<String> alphabet,
    NFATransitionFn<StateType> transitions,
    FAState<StateType> initialState,
    Set<FAState<StateType>> acceptingStates,
  ) {
    return FAValidator.ensureStatesExist(states).flatMap((validStates) {
      return FAValidator.ensureSymbolsValid(alphabet).flatMap((validAlphabet) {
        return FAValidator.ensureAllNFATransitionsValid(
          transitions,
          validStates,
          validAlphabet,
        ).flatMap((validTransitions) {
          return FAValidator.ensureInitialStateExists(initialState, validStates).flatMap((validInitialState) {
            return FAValidator.ensureAcceptingStatesExists(acceptingStates, validStates).map((validAcceptingStates) {
              return NFA<StateType>._(
                validStates,
                validAlphabet,
                validTransitions,
                validInitialState,
                validAcceptingStates,
              );
            });
          });
        });
      });
    });
  }

  Either<String, Stream<List<MachineConfiguration<StateType>>>> getAllAcceptedTraces(String input) {
    return buildComputationTree(input).map((tree) {
      return _allRootToLeafTracesStream(tree).where(_checkTraceIsAccepted);
    });
  }

  Either<String, ComputationTree<StateType>> buildComputationTree(String input) {
    if (isEpsilonNFA) return Left('Computation tree for epsilon-NFA not implemented yet.');

    final (_, computationTree) = _buildComputationTree(initialState, input, depth: 0, nodeId: 0);

    return Right(computationTree);
  }

  // TODO: Remove unnecessary and dead states
  NFA<StateType> eliminateEpsilonTransitions() {
    final newTransitions = Map.fromEntries(states.flatMap((state) {
      return alphabet.map((symbol) {
        final nextStates = epsilonClosure(move(epsilonClosure({state}), symbol));

        return MapEntry((state, Some(symbol)), nextStates);
      });
    }));

    final newAcceptingStates = states.where((state) => epsilonClosure({state}).any(acceptingStates.contains)).toSet();

    return NFA._(states, alphabet, newTransitions, initialState, newAcceptingStates);
  }

  Either<String, DFA<String>> toDFA() {
    final Set<String> dfaAlphabet = alphabet;
    final FAStateSet<StateType> dfaInitialState = EquatableSet(epsilonClosure({initialState}));

    Set<FAStateSet<StateType>> dfaStates = {};
    List<({FAStateSet<StateType> from, String symbol, FAStateSet<StateType> to})> dfaSubsetConstructionTable = [];
    Set<FAStateSet<StateType>> unprocessedDFAStates = {dfaInitialState};

    while (unprocessedDFAStates.isNotEmpty) {
      final FAStateSet<StateType> currentDFAState = unprocessedDFAStates.first;

      final List<({FAStateSet<StateType> from, String symbol, FAStateSet<StateType> to})> transitionsInitialState = [];
      final dfaTransitionsForAlphabet = dfaAlphabet.fold(transitionsInitialState, (transitions, symbol) {
        final transition = (
          from: currentDFAState,
          symbol: symbol,
          to: EquatableSet(epsilonClosure(move(currentDFAState, symbol))),
        );

        return [...transitions, transition];
      });

      final newUnprocessedDFAStates = dfaTransitionsForAlphabet.map((_) => _.to).whereNot((_) {
        return _ == currentDFAState || dfaStates.contains(_);
      });

      dfaStates = {...dfaStates, currentDFAState};
      unprocessedDFAStates = {...unprocessedDFAStates.skip(1), ...newUnprocessedDFAStates};
      dfaSubsetConstructionTable = [...dfaSubsetConstructionTable, ...dfaTransitionsForAlphabet];
    }

    final dfaAcceptingStates = dfaStates.where((state) => state.any(acceptingStates.contains)).toSet();

    return _createDFA(
      dfaStates,
      dfaAlphabet,
      dfaSubsetConstructionTable,
      dfaInitialState,
      dfaAcceptingStates,
      _convertToState,
    );
  }

  bool isAccepted(String input) {
    final initialValue = epsilonClosure({initialState});

    final Set<FAState<StateType>> currentStates = input.split('').fold(initialValue, (states, symbol) {
      return epsilonClosure(move(states, symbol));
    });

    return currentStates.any(acceptingStates.contains);
  }

  Set<FAState<StateType>> epsilonClosure(Set<FAState<StateType>> states) {
    return states.map((state) => _epsilonClosure(state, {})).fold({}, union);
  }

  Set<FAState<StateType>> move(Set<FAState<StateType>> states, String symbol) {
    return states.map((state) => _move(state, symbol)).fold({}, union);
  }

  Option<Set<FAState<StateType>>> transitionFunction(FAState<StateType> state, Option<String> symbol) {
    return transitions.extract<Set<FAState<StateType>>>((state, symbol));
  }

  bool _checkTraceIsAccepted(List<MachineConfiguration<StateType>> trace) {
    final lastMachineConfiguration = trace.last;

    final isDeadConfiguration = lastMachineConfiguration.unprocessedInput.isNotEmpty;
    final isNFAStoppedOnAcceptingState = acceptingStates.contains(lastMachineConfiguration.currentState);

    return !isDeadConfiguration && isNFAStoppedOnAcceptingState;
  }

  Stream<List<MachineConfiguration<StateType>>> _allRootToLeafTracesStream(ComputationTree<StateType> tree) {
    Stream<List<MachineConfiguration<StateType>>> dfsStream(
      ComputationTree<StateType> node,
      List<MachineConfiguration<StateType>> currentTrace,
    ) async* {
      final newTrace = [...currentTrace, node.machineConfiguration];

      if (node.isLeaf) {
        yield newTrace;
      } else {
        for (var child in node.children) {
          yield* dfsStream(child, newTrace);
        }
      }
    }

    return dfsStream(tree, []);
  }

  (int, ComputationTree<StateType>) _buildComputationTree(
    FAState<StateType> currentState,
    String unprocessedInput, {
    required int depth,
    required int nodeId,
  }) {
    final configuration = MachineConfiguration(currentState, unprocessedInput);

    if (unprocessedInput.isEmpty) return (nodeId, ComputationTree(configuration, id: nodeId, depth: depth));

    final nextStates = _move(currentState, unprocessedInput[0]);

    if (nextStates.isEmpty) return (nodeId, ComputationTree(configuration, id: nodeId, depth: depth));

    final initialValue = (lastNodeId: nodeId + 1, children: <ComputationTree<StateType>>[]);
    final (lastNodeId: lastChildrenNodeId, children: children) = nextStates.foldIndexed(
      initialValue,
      (index, res, nextState) {
        final (lastNodeId, computationTree) = _buildComputationTree(
          nextState,
          unprocessedInput.substring(1),
          depth: depth + 1,
          nodeId: res.lastNodeId + index,
        );

        return (lastNodeId: lastNodeId, children: [...res.children, computationTree]);
      },
    );

    return (lastChildrenNodeId, ComputationTree(configuration, id: nodeId, depth: depth, children: children));
  }

  Either<String, DFA<T>> _createDFA<T>(
    Set<FAStateSet<StateType>> states,
    Set<String> alphabet,
    List<({FAStateSet<StateType> from, String symbol, FAStateSet<StateType> to})> subsetConstructionTable,
    FAStateSet<StateType> initialState,
    Set<FAStateSet<StateType>> acceptingStates,
    FAState<T> Function(int index, FAStateSet<StateType> states) namingFunction,
  ) {
    final dfaWithCorrespondingNFAStates = Map<FAState<T>, FAStateSet<StateType>>.fromEntries(
      states.where((_) => _.isNotEmpty).mapIndexed(
        (index, stateSet) {
          return MapEntry(namingFunction(index, stateSet), stateSet);
        },
      ),
    );

    FAState<T> getStateFromCorrespondingNFAStates(FAStateSet<StateType> nfaStates) {
      return dfaWithCorrespondingNFAStates.entries.singleWhere((_) => nfaStates == _.value).key;
    }

    final namedDFAStates = states.where((_) => _.isNotEmpty).map(getStateFromCorrespondingNFAStates).toSet();
    final namedInitialState = getStateFromCorrespondingNFAStates(initialState);
    final namedDFAAcceptingStates =
        acceptingStates.where((_) => _.isNotEmpty).map(getStateFromCorrespondingNFAStates).toSet();

    final namedTransitionFunction = Map.fromEntries(
      subsetConstructionTable.where((_) => _.from.isNotEmpty && _.to.isNotEmpty).map((_) {
        return MapEntry(
          (getStateFromCorrespondingNFAStates(_.from), _.symbol),
          getStateFromCorrespondingNFAStates(_.to),
        );
      }),
    );

    return DFA.createDFA(namedDFAStates, alphabet, namedTransitionFunction, namedInitialState, namedDFAAcceptingStates);
  }

  FAState<String> _convertToState(int index, FAStateSet<StateType> states) {
    return FAState(states.map((__) => __.name).join('_'));
  }

  Set<FAState<StateType>> _epsilonClosure(FAState<StateType> state, Set<FAState<StateType>> visitedStates) {
    final Set<FAState<StateType>> newStates = _reachableStates(state, None())
        .whereNot(visitedStates.contains)
        .flatMap((nextState) => _epsilonClosure(nextState, {...visitedStates, state}))
        .toSet();

    return visitedStates.union(newStates).union({state});
  }

  Set<FAState<StateType>> _move(FAState<StateType> state, String symbol) {
    return _reachableStates(state, Some(symbol));
  }

  Set<FAState<StateType>> _reachableStates(FAState<StateType> state, Option<String> symbol) {
    return transitionFunction(state, symbol).getOrElse(() => {});
  }

  bool get isEpsilonNFA {
    return transitions.keys.map((e) => e.$2).any((symbolOption) {
      return symbolOption.isNone();
    });
  }

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final NFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> acceptingStates;
}
