import 'fa_state.dart';

class TransitionStep<StateType> {
  const TransitionStep(this.currentState, this.unprocessedInput);

  final FAState<StateType> currentState;
  final String unprocessedInput;
}
