import 'package:automata_simulator/src/dfa_minimization.dart';

import 'dfa_collection.dart';
import 'utils.dart';

void main() {
  var numberDFAEither = createNumberDFA();

  numberDFAEither.fold(
    (error) => print('Error: $error'),
    (dfa) {
      final List<String> testCases = ['451.2351', '145.', '12ah'];

      final reports = testCases.map((testCase) => generateDFAReportForInput(dfa, testCase));

      final completeDFAWithoutUnreachableStates = dfa.toComplete(
        (states) {
          return genStringSinkState(states, 'SinkState');
        },
      ).withoutUnreachableStates();

      minimizeDFA(completeDFAWithoutUnreachableStates).fold(
        (error) => print('Error: $error'),
        (minimizedDFA) {
          print('DFA:');
          print(prettyDFA(dfa));
          print('');
          print('Minimized DFA:');

          print(prettyDFA(minimizedDFA));
          print('');
        },
      );

      reports.forEach(print);
    },
  );
}
