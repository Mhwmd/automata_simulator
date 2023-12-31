import 'package:automata_simulator/src/machine_configuration.dart';
import 'package:automata_simulator/src/utils.dart';
import 'package:fpdart/fpdart.dart';

import 'computation_tree.dart';
import 'dfa.dart';
import 'fa_state.dart';
import 'nfa.dart';

typedef _TransitionFunction<StateType, SymbolType> = Map<(FAState<StateType>, FAState<StateType>), Set<SymbolType>>;

class FADotGraph {
  FADotGraph._();

  static String exportDFA<StateType>(DFA<StateType> dfa) {
    final transitionsWithCollectedSymbols = _collectDFASymbolsWithSameTransition(dfa.transitions);

    final nonAcceptingStates = dfa.states.difference(dfa.acceptingStates);

    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln('digraph DFA {');

    stringBuffer.writeln(_indent(1, 'rankdir=LR;'));
    stringBuffer.writeln(_indent(1, 'size="8,5";'));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _startNode('_start_')));
    stringBuffer.writeln('');

    if (nonAcceptingStates.isNotEmpty) {
      stringBuffer.writeln(_indent(1, _nonAcceptingNodes(nonAcceptingStates.map((e) => e.name.toString()).toSet())));
    }
    if (dfa.acceptingStates.isNotEmpty) {
      stringBuffer.writeln(_indent(1, _acceptingNodes(dfa.acceptingStates.map((e) => e.name.toString()).toSet())));
    }
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _transitionNode('_start_', dfa.initialState.name.toString(), 'Start')));
    stringBuffer.writeln('');

    transitionsWithCollectedSymbols.forEach((transitionNodes, symbols) {
      final (firstNode, secondNode) = transitionNodes;
      final edgeLabel = symbols.join(', ');

      stringBuffer.writeln(_indent(
        1,
        _transitionNode(
          firstNode.name.toString(),
          secondNode.name.toString(),
          edgeLabel,
        ),
      ));
    });

    stringBuffer.writeln('}');

    return stringBuffer.toString();
  }

  static String exportNFA<StateType>(NFA<StateType> nfa) {
    final transitionsWithCollectedSymbols = _collectNFASymbolsWithSameTransition(nfa.transitions);

    final nonAcceptingStates = nfa.states.difference(nfa.acceptingStates);

    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln('digraph NFA {');

    stringBuffer.writeln(_indent(1, 'rankdir=LR;'));
    stringBuffer.writeln(_indent(1, 'size="8,5";'));
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _startNode('_start_')));
    stringBuffer.writeln('');

    if (nonAcceptingStates.isNotEmpty) {
      stringBuffer.writeln(_indent(1, _nonAcceptingNodes(nonAcceptingStates.map((e) => e.name.toString()).toSet())));
    }
    if (nfa.acceptingStates.isNotEmpty) {
      stringBuffer.writeln(_indent(1, _acceptingNodes(nfa.acceptingStates.map((e) => e.name.toString()).toSet())));
    }
    stringBuffer.writeln('');

    stringBuffer.writeln(_indent(1, _transitionNode('_start_', nfa.initialState.name.toString(), 'Start')));
    stringBuffer.writeln('');

    transitionsWithCollectedSymbols.forEach((transitionNodes, symbols) {
      final (firstNode, secondNode) = transitionNodes;
      final edgeLabel = symbols.map((e) => e.getOrElse(() => 'ε')).join(', ');

      stringBuffer.writeln(_indent(
        1,
        _transitionNode(
          firstNode.name.toString(),
          secondNode.name.toString(),
          edgeLabel,
        ),
      ));
    });

    stringBuffer.writeln('}');

    return stringBuffer.toString();
  }

  static String exportNFAComputationTree<StateType>(NFA<StateType> nfa, ComputationTree<StateType> computationTree) {
    final List<({int nodeId, MachineConfiguration<StateType> machineConfiguration, bool isLeaf})> nodesInfo = [];
    final List<({int nodeId, List<int> childrenNodeIds, String symbol})> edgesInfo = [];

    void prepareComputationTreeForDot(ComputationTree<StateType> node) {
      final machineConfiguration = node.machineConfiguration;

      nodesInfo.add((
        nodeId: node.id,
        machineConfiguration: machineConfiguration,
        isLeaf: node.isLeaf,
      ));

      if (!node.isLeaf) {
        final String symbol = node.machineConfiguration.unprocessedInput[0];
        final childrenNodeIds = node.children.map((child) => child.id).toList();

        edgesInfo.add((nodeId: node.id, childrenNodeIds: childrenNodeIds, symbol: symbol));

        node.children.forEach(prepareComputationTreeForDot);
      }
    }

    prepareComputationTreeForDot(computationTree);

    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.writeln('digraph ComputationTree {');

    stringBuffer.writeln(_indent(1, 'rankdir=TB;'));
    stringBuffer.writeln(_indent(1, 'size="8,5";'));
    stringBuffer.writeln('');

    for (var nodeInfo in nodesInfo) {
      final isAcceptingState = nfa.acceptingStates.contains(nodeInfo.machineConfiguration.currentState);
      final String shape = isAcceptingState ? 'doublecircle' : 'circle';

      bool isAcceptedLeaf = false;
      if (nodeInfo.isLeaf) {
        final isDeadConfiguration = nodeInfo.machineConfiguration.unprocessedInput.isNotEmpty;
        final isDFAStoppedOnAcceptingState = nfa.acceptingStates.contains(nodeInfo.machineConfiguration.currentState);

        isAcceptedLeaf = !isDeadConfiguration && isDFAStoppedOnAcceptingState;
      }

      final String color = isAcceptedLeaf ? 'green' : 'red';
      stringBuffer.writeln(
        _indent(
          1,
          '"${nodeInfo.nodeId}" [ shape = $shape ${nodeInfo.isLeaf ? 'color = "$color"' : ''} label = "${nodeInfo.machineConfiguration.currentState.name}" ];',
        ),
      );
    }

    stringBuffer.writeln('');

    for (var edgeInfo in edgesInfo) {
      stringBuffer.writeln(
        _indent(
          1,
          '"${edgeInfo.nodeId}" -> {${edgeInfo.childrenNodeIds.map((e) => '"$e"').join(' ')}} [ label = "  ${edgeInfo.symbol}  " ];',
        ),
      );
    }

    stringBuffer.writeln('}');

    return stringBuffer.toString();
  }

  static _TransitionFunction<StateType, String> _collectDFASymbolsWithSameTransition<StateType>(
    DFATransitionFn<StateType> transitions,
  ) {
    return transitions.entries.fold({}, (res, transitionFnEntry) {
      final transitionFn = (
        currentState: transitionFnEntry.key.$1,
        symbol: transitionFnEntry.key.$2,
        nextState: transitionFnEntry.value,
      );

      return res.immutableUpdate(
        (transitionFn.currentState, transitionFn.nextState),
        (symbols) => {...symbols, transitionFn.symbol},
        ifAbsent: () => {transitionFn.symbol},
      );
    });
  }

  static _TransitionFunction<StateType, Option<String>> _collectNFASymbolsWithSameTransition<StateType>(
    NFATransitionFn<StateType> transitions,
  ) {
    final flattenTransitions = transitions.entries.flatMap((transitionFnEntry) {
      final transitionFn = (
        currentState: transitionFnEntry.key.$1,
        symbol: transitionFnEntry.key.$2,
        nextStates: transitionFnEntry.value,
      );

      return transitionFn.nextStates.map((nextState) {
        return (currentState: transitionFn.currentState, nextState: nextState, symbol: transitionFn.symbol);
      });
    });

    return flattenTransitions.fold({}, (res, transitionFn) {
      return res.immutableUpdate(
        (transitionFn.currentState, transitionFn.nextState),
        (symbols) => {...symbols, transitionFn.symbol},
        ifAbsent: () => {transitionFn.symbol},
      );
    });
  }

  static String _indent(int n, String str) => '\t' * n + str;

  static String _wrapInDoubleQuotes(String str) => '"$str"';

  static String _nodes(String shape, Set<String> nodesName) {
    return 'node [shape = $shape ]; ${nodesName.map(_wrapInDoubleQuotes).join(' ')};';
  }

  static String _acceptingNodes(Set<String> nodesName) => _nodes('doublecircle', nodesName);

  static String _nonAcceptingNodes(Set<String> nodesName) => _nodes('circle', nodesName);

  static String _startNode(String nodeName) => _nodes('point', {nodeName});

  static String _transitionNode(String fromNodeName, String toNodeName, String label) {
    return '${_wrapInDoubleQuotes(fromNodeName)} -> ${_wrapInDoubleQuotes(toNodeName)} [ label = "$label" ];';
  }
}
