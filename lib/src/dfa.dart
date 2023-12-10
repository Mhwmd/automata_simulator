import 'fa_state.dart';

typedef DFATransitionFn<StateType> = Map<(FAState<StateType>, String), FAState<StateType>>;

class DFA<StateType> {
  DFA(this.states, this.alphabet, this.transitions, this.initialState, this.acceptingStates);

  final Set<FAState<StateType>> states;
  final Set<String> alphabet;
  final DFATransitionFn<StateType> transitions;
  final FAState<StateType> initialState;
  final Set<FAState<StateType>> acceptingStates;
}
