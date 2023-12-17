import 'package:automata_simulator/automata_simulator.dart';

String generateDFAReportForInput(DFA dfa, String inputString) {
  final StringBuffer stringBuffer = StringBuffer();

  stringBuffer.writeln('=' * 30);
  stringBuffer.writeln('Input: $inputString');
  stringBuffer.writeln('=' * 30);

  stringBuffer.writeln('Accepted: ${dfa.isAccepted(inputString)}');
  stringBuffer.writeln('Machine Configuration: ${dfa.generateMachineConfiguration(inputString)}');
  stringBuffer.write('Extended Function: ');
  stringBuffer.writeln(dfa.generateExtendedTransitionSteps(inputString).join('\n = '));

  stringBuffer.writeln('');
  stringBuffer.writeln('Accepting States are: ${dfa.acceptingStates.map((e) => e.name).join(', ')}');

  return stringBuffer.toString();
}

String prettyDFA(DFA dfa) {
  final String transitionFn = dfa.transitions.entries
      .map((entry) => '&(${entry.key.$1.name}, ${entry.key.$2}) = ${entry.value.name}')
      .join('\n');

  final String machine =
      'M({${dfa.states.map((e) => e.name).join(', ')}}, ${dfa.alphabet}, &, ${dfa.initialState.name}, {${dfa.acceptingStates.map((e) => e.name).join(', ')}})';

  return '$machine\n$transitionFn';
}

FAState<String> genStringSinkState(Set<FAState<String>> states, String name) {
  if (!states.contains(FAState(name))) return FAState(name);

  return genStringSinkState(states, '_$name');
}

FAState<int> genIntegerSinkState(Set<FAState<int>> states, int n) {
  if (!states.contains(FAState(n))) return FAState(n);

  return genIntegerSinkState(states, n + 1);
}
