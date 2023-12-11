import 'dfa_collection.dart';
import 'utils.dart';

void main() {
  var numberDFAEither = createNumberDFA();

  numberDFAEither.fold(
    (error) => print('Error: $error'),
    (dfa) {
      final List<String> testCases = ['451.2351', '145.', '12ah'];

      final reports = testCases.map((testCase) => generateDFAReportForInput(dfa, testCase));

      reports.forEach(print);
    },
  );
}
