import 'package:fpdart/fpdart.dart';

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
    return Either.fromPredicate(
      acceptingStates,
      (acceptingStates) => acceptingStates.every(states.contains),
      (_) => 'All accepting states must belong to the set of states.',
    );
  }
}
