import 'fa_state.dart';

class MachineConfiguration<StateType> {
  const MachineConfiguration(this.currentState, this.unprocessedInput);

  final FAState<StateType> currentState;
  final String unprocessedInput;
}
