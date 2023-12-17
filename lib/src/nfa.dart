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

  Option<Set<FAState<StateType>>> transitionFunction(FAState<StateType> state, Option<String> symbol) {
    return transitions.extract<Set<FAState<StateType>>>((state, symbol));
  }

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final NFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> finalStates;
}
