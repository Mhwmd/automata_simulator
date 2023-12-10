import 'package:fpdart/fpdart.dart';

import 'dfa.dart';
import 'fa_state.dart';

class FAValidator {
  FAValidator._();

  static Either<String, Set<FAState<T>>> ensureStatesExist<T>(Set<FAState<T>> states) {
    return Either.fromPredicate(
      states,
      (r) => r.isNotEmpty,
      (_) => 'At least one state needed for FA',
    );
  }

  static Either<String, Set<String>> ensureSymbolsValid(Set<String> alphabet) {
    return Either.fromPredicate(
      alphabet,
      (alphabet) => alphabet.every((symbol) => symbol.length == 1),
      (_) => 'Each symbol in the alphabet must be a single character.',
    );
  }

  static Either<String, FAState<T>> ensureInitialStateExists<T>(FAState<T> initialState, Set<FAState<T>> states) {
    return Either.fromPredicate(
      initialState,
      (state) => states.contains(state),
      (state) => 'The initial state $state must belong to the set of states.',
    );
  }

  static Either<String, Set<FAState<T>>> ensureAcceptingStatesExists<T>(
    Set<FAState<T>> acceptingStates,
    Set<FAState<T>> states,
  ) {
    if (acceptingStates.isEmpty) return Left('At least one accepting state needed for FA');

    return Either.fromPredicate(
      acceptingStates,
      (acceptingStates) => acceptingStates.every(states.contains),
      (_) => 'All accepting states must belong to the set of states.',
    );
  }

  static Either<String, DFATransitionFn<T>> ensureAllDFATransitionsValid<T>(
    DFATransitionFn<T> transitions,
    Set<FAState<T>> states,
    Set<String> alphabet,
  ) {
    return Either.fromPredicate(
      transitions,
      (transitions) {
        return transitions.entries.every((fn) {
          final transition = (state: fn.key.$1, symbol: fn.key.$2, nextState: fn.value);

          return states.contains(transition.state) &&
              states.contains(transition.nextState) &&
              alphabet.contains(transition.symbol);
        });
      },
      (_) {
        return 'All transitions in the transition function must have states and symbols that belong to the defined sets (states and alphabet).';
      },
    );
  }

  static bool isValidDFA<T>(DFA<T> dfa) {
    final dfaValidations = [
      FAValidator.ensureStatesExist(dfa.states),
      FAValidator.ensureSymbolsValid(dfa.alphabet),
      FAValidator.ensureAllDFATransitionsValid(dfa.transitions, dfa.states, dfa.alphabet),
      FAValidator.ensureInitialStateExists(dfa.initialState, dfa.states),
      FAValidator.ensureAcceptingStatesExists(dfa.acceptingStates, dfa.states),
    ];

    return dfaValidations.all((validation) => validation.isRight());
  }
}
