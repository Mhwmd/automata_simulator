import 'package:automata_simulator/src/dfa.dart';

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
