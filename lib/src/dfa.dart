import 'package:automata_simulator/src/transition_step.dart';
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

  DFA<StateType> withoutUnreachableStates() {
    final newStates = reachableStates;

    final DFATransitionFn<StateType> newTransitionFunction = Map.fromEntries(transitions.entries.where((entry) {
      final transition = (state: entry.key.$1, symbol: entry.key.$2, nextState: entry.value);

      return newStates.contains(transition.state) && newStates.contains(transition.nextState);
    }));

    final newAcceptingStates = acceptingStates.intersection(newStates);

    return DFA._(newStates, alphabet, newTransitionFunction, initialState, newAcceptingStates);
  }

  bool isAccepted(String inputString) {
    final transitionSteps = extendedTransitionFunction(initialState, inputString);

    return transitionSteps.lastOption.match(() => false, (lastStep) {
      final isEntireInputProcessed = lastStep.unprocessedInput.isEmpty;
      final isDFAStoppedOnAcceptingState = acceptingStates.contains(lastStep.currentState);

      return isEntireInputProcessed && isDFAStoppedOnAcceptingState;
    });
  }

  String generateMachineConfiguration(String inputString) {
    final transitionSteps = extendedTransitionFunction(initialState, inputString);

    return transitionSteps.map((step) {
      return '[${step.currentState.name}, ${_getStringOrEpsilon(step.unprocessedInput)}]';
    }).join('|-');
  }

  List<String> generateExtendedTransitionSteps(String inputString) {
    final transitionSteps = extendedTransitionFunction(initialState, inputString);
    final firstStep = transitionSteps.first;
    final initialValue = <String>[
      _formatExtendedTransition(
        firstStep.currentState.name.toString(),
        _getStringOrEpsilon(firstStep.unprocessedInput),
      )
    ];

    return transitionSteps.fold(initialValue, (stringSteps, step) {
      if (step.unprocessedInput.isEmpty) return stringSteps;

      final String symbol = step.unprocessedInput[0];
      final String remainingString = step.unprocessedInput.substring(1);
      final String delta = _formatTransition(step.currentState, symbol);

      final nextStateOption = transitionFunction(step.currentState, symbol);

      if (remainingString.isEmpty) {
        return nextStateOption.fold(
          () => [...stringSteps, delta],
          (nextState) => [...stringSteps, '$delta = ${nextState.name}'],
        );
      }

      return [
        ...stringSteps,
        nextStateOption.fold(
          () => _formatExtendedTransition(delta, remainingString),
          (nextState) {
            return '${_formatExtendedTransition(delta, remainingString)} => ${_formatExtendedTransition(nextState.name.toString(), remainingString)}';
          },
        ),
      ];
    });
  }

  List<TransitionStep<StateType>> extendedTransitionFunction(FAState<StateType> state, String inputString) {
    final initialValue = [TransitionStep(state, inputString)];

    return inputString.split('').fold(initialValue, (steps, symbol) {
      final lastStep = steps.last;
      final nextUnprocessedInput = lastStep.unprocessedInput.substring(1);
      final nextStateOption = transitionFunction(lastStep.currentState, symbol);

      return nextStateOption.fold(
        () => steps,
        (nextState) => [...steps, TransitionStep(nextState, nextUnprocessedInput)],
      );
    });
  }

  Option<FAState<StateType>> transitionFunction(FAState<StateType> state, String symbol) {
    return transitions.extract<FAState<StateType>>((state, symbol));
  }

  String _formatExtendedTransition(String deltaOrState, String remainingString) {
    return 'δ^($deltaOrState, ${_getStringOrEpsilon(remainingString)})';
  }

  String _formatTransition(FAState<StateType> currentState, String symbol) {
    return 'δ(${currentState.name}, $symbol)';
  }

  String _getStringOrEpsilon(String str) => str.isNotEmpty ? str : 'ε';

  Set<FAState<StateType>> _filterReachableStates(FAState<StateType> state, Set<FAState<StateType>> visited) {
    if (visited.contains(state)) return visited;

    return alphabet
        .map((symbol) => transitionFunction(state, symbol))
        .whereType<Some<FAState<StateType>>>()
        .map((nextState) => nextState.value)
        .fold(visited.union({state}), (visitedStates, nextState) => _filterReachableStates(nextState, visitedStates));
  }

  Set<FAState<StateType>> get reachableStates => _filterReachableStates(initialState, {}).toSet();

  Set<FAState<StateType>> get unreachableStates => states.difference(reachableStates);

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final DFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> acceptingStates;
}
