import 'package:fpdart/fpdart.dart';

import 'fa_state.dart';
import 'fa_validator.dart';
import 'transition_step.dart';

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

  bool isAccepted(String inputString) {
    final transitionSteps = extendedTransitionFunction(initialState, inputString);

    return transitionSteps.lastOption.match(() => false, (lastStep) {
      final isDFAStoppedOnAcceptingState = acceptingStates.contains(lastStep.currentState);
      final isEntireInputProcessed = acceptingStates.contains(lastStep.currentState);

      return isEntireInputProcessed && isDFAStoppedOnAcceptingState;
    });
  }

  List<TransitionStep<StateType>> extendedTransitionFunction(FAState<StateType> state, String remainingString) {
    return _extendedTransitionFunction(state, remainingString, []);
  }

  List<TransitionStep<StateType>> _extendedTransitionFunction(
    FAState<StateType> state,
    String remainingString,
    List<TransitionStep<StateType>> steps,
  ) {
    final newSteps = [...steps, TransitionStep(state, remainingString)];

    if (remainingString.isEmpty) return newSteps;

    final nextStateOption = transitionFunction(state, remainingString[0]);

    return nextStateOption.fold(
      () => newSteps,
      (nextState) => _extendedTransitionFunction(nextState, remainingString.substring(1), newSteps),
    );
  }

  Option<FAState<StateType>> transitionFunction(FAState<StateType> state, String symbol) {
    return transitions.extract<FAState<StateType>>((state, symbol));
  }

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final DFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> acceptingStates;
}
