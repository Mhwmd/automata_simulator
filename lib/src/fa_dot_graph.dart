import 'package:fpdart/fpdart.dart';

import 'dfa.dart';
import 'fa_state.dart';
import 'nfa.dart';
import 'utils.dart';

class FADotGraph {
  FADotGraph._();

  static String exportDFA<StateType>(DFA<StateType> dfa) {
    final nonAcceptingStates = dfa.states.difference(dfa.acceptingStates);
    final Map<(FAState<StateType>, FAState<StateType>), Set<String>> transitionSymbols = {};
    dfa.transitions.forEach((key, nextState) {
      transitionSymbols.update((key.$1, nextState), (symbols) => {...symbols, key.$2}, ifAbsent: () => {key.$2});
    });

    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln('digraph DFA {');

    stringBuffer.writeln(_indent(1, 'rankdir=LR;'));
    stringBuffer.writeln(_indent(1, 'size="8,5";'));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _startNode('_start_')));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _nonAcceptingNode(nonAcceptingStates.map((e) => e.name.toString()).join(' '))));
    stringBuffer.writeln(_indent(1, _acceptingNode(dfa.acceptingStates.map((e) => e.name.toString()).join(' '))));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _transitionNode('_start_', dfa.initialState.name.toString(), 'Start')));
    stringBuffer.writeln('');

    stringBuffer.writeAll(
      transitionSymbols.entries.map((e) {
        final transition = (from: e.key.$1, to: e.key.$2, symbols: e.value);

        return _transitionNode(
          transition.from.name.toString(),
          transition.to.name.toString(),
          transition.symbols.join(', '),
        );
      }).map((e) => _indent(1, e)),
      '\n',
    );
    stringBuffer.writeln('');

    stringBuffer.writeln('}');

    return stringBuffer.toString();
  }

  static String exportNFA<StateType>(NFA<StateType> nfa) {
    final nonAcceptingStates = nfa.states.difference(nfa.acceptingStates);
    final Map<(FAState<StateType>, EquatableSet<FAState<StateType>>), Set<Option<String>>> transitionSymbols = {};
    nfa.transitions.forEach((key, nextStates) {
      transitionSymbols.update(
        (key.$1, EquatableSet(nextStates)),
        (symbols) => {...symbols, key.$2},
        ifAbsent: () => {key.$2},
      );
    });

    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln('digraph NFA {');

    stringBuffer.writeln(_indent(1, 'rankdir=LR;'));
    stringBuffer.writeln(_indent(1, 'size="8,5";'));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _startNode('_start_')));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _nonAcceptingNode(nonAcceptingStates.map((e) => e.name.toString()).join(' '))));
    stringBuffer.writeln(_indent(1, _acceptingNode(nfa.acceptingStates.map((e) => e.name.toString()).join(' '))));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _transitionNode('_start_', nfa.initialState.name.toString(), 'Start')));
    stringBuffer.writeln('');

    transitionSymbols.forEach((key, symbolsEdge) {
      final transitionsNode = key.$2.map((nextState) {
        return _indent(
          1,
          _transitionNode(
            key.$1.name.toString(),
            nextState.name.toString(),
            symbolsEdge.map((e) => e.getOrElse(() => 'ε')).join(', '),
          ),
        );
      });

      stringBuffer.writeAll(transitionsNode, '\n');
    });

    stringBuffer.writeln('}');

    return stringBuffer.toString();
  }

  static String _indent(int n, String str) => '\t' * n + str;

  static String _node(String shape, String nodeName) => 'node [shape = $shape ]; $nodeName;';

  static String _acceptingNode(String nodeName) => _node('doublecircle', nodeName);

  static String _nonAcceptingNode(String nodeName) => _node('circle', nodeName);

  static String _startNode(String nodeName) => _node('point', nodeName);

  static String _transitionNode(String fromNodeName, String toNodeName, String label) {
    return '$fromNodeName -> $toNodeName [ label = "$label" ];';
  }
}
