import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';

import 'fa_state.dart';
import 'fa_validator.dart';
import 'utils.dart';

typedef FAStateSet<T> = EquatableSet<FAState<T>>;
typedef NFATransitionFn<T> = Map<(FAState<T>, Option<String>), Set<FAState<T>>>;

class NFA<StateType> {
  NFA._(this.states, this.alphabet, this.transitions, this.initialState, this.finalStates);

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

  bool isAccepted(String input) {
    final initialValue = epsilonClosure({initialState});

    final Set<FAState<StateType>> currentStates = input.split('').fold(initialValue, (states, symbol) {
      return epsilonClosure(move(states, symbol));
    });

    return currentStates.any(finalStates.contains);
  }

  Set<FAState<StateType>> epsilonClosure(Set<FAState<StateType>> states) {
    return states.flatMap((state) => _epsilonClosure(state, {})).toSet();
  }

  Set<FAState<StateType>> move(Set<FAState<StateType>> states, String symbol) {
    return states.flatMap((state) => _move(state, symbol)).toSet();
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

  Option<Set<FAState<StateType>>> transitionFunction(FAState<StateType> state, Option<String> symbol) {
    return transitions.extract<Set<FAState<StateType>>>((state, symbol));
  }

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final NFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> finalStates;
}
