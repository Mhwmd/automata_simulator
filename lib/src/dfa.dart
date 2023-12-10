import 'package:fpdart/fpdart.dart';

import 'fa_state.dart';
import 'fa_validator.dart';

typedef DFATransitionFn<StateType> = Map<(FAState<StateType>, String), FAState<StateType>>;

class DFA<StateType> {
  DFA._(this.states, this.alphabet, this.transitions, this.initialState, this.acceptingStates);

  static Either<String, DFA<StateType>> createDFA<StateType>(
    Set<FAState<StateType>> states,
    Set<String> alphabet,
    DFATransitionFn<StateType> transitions,
    FAState<StateType> initialState,
    Set<FAState<StateType>> acceptingStates,
  ) {
    return FAValidator.ensureStatesExist(states).flatMap((validStates) {
      return FAValidator.ensureSymbolsValid(alphabet).flatMap((validAlphabet) {
        return FAValidator.ensureAllDFATransitionsValid(
          transitions,
          validStates,
          validAlphabet,
        ).flatMap((validTransitions) {
          return FAValidator.ensureInitialStateExists(initialState, validStates).flatMap((validInitialState) {
            return FAValidator.ensureAcceptingStatesExists(acceptingStates, validStates).map((validAcceptingStates) {
              return DFA<StateType>._(
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

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final DFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> acceptingStates;
}
