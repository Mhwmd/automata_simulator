import 'package:automata_simulator/automata_simulator.dart';
import 'package:fpdart/fpdart.dart';

Either<String, NFA<String>> createNFA1() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2')};
  final Set<String> alphabet = {'a', 'b'};

  final Map<(FAState<String>, Option<String>), Set<FAState<String>>> transitionFunction = {
    (FAState('q0'), Some('a')): {FAState('q0')},
    (FAState('q0'), Some('b')): {FAState('q0'), FAState('q1')},
    (FAState('q1'), Some('b')): {FAState('q2')},
  };

  final initialState = FAState('q0');
  final finalStates = <FAState<String>>{FAState('q2')};

  return NFA.createNFA(states, alphabet, transitionFunction, initialState, finalStates);
}

// nfa (a|b)(a|b)
Either<String, NFA<int>> createNFA2() {
  final states = {
    FAState(0),
    FAState(1),
    FAState(2),
    FAState(3),
    FAState(4),
    FAState(5),
    FAState(6),
    FAState(7),
    FAState(8),
    FAState(9),
    FAState(10),
  };

  final Set<String> alphabet = {'a', 'b'};

  final Map<(FAState<int>, Option<String>), Set<FAState<int>>> transitionFunction = {
    (FAState(0), None()): {FAState(1), FAState(3)},
    (FAState(1), Some('a')): {FAState(2)},
    (FAState(2), None()): {FAState(5)},
    (FAState(3), Some('b')): {FAState(4)},
    (FAState(4), None()): {FAState(5)},
    (FAState(5), None()): {FAState(6), FAState(8)},
    (FAState(6), Some('a')): {FAState(7)},
    (FAState(7), None()): {FAState(10)},
    (FAState(8), Some('b')): {FAState(9)},
    (FAState(9), None()): {FAState(10)},
  };

  final initialState = FAState(0);
  final finalStates = <FAState<int>>{FAState(10)};

  return NFA.createNFA(states, alphabet, transitionFunction, initialState, finalStates);
}

// nfa (a|b)*a
Either<String, NFA<int>> createNFA3() {
  final states = {
    FAState(0),
    FAState(1),
    FAState(2),
    FAState(3),
    FAState(4),
    FAState(5),
    FAState(6),
    FAState(7),
    FAState(8),
  };

  final Set<String> alphabet = {'a', 'b'};

  final Map<(FAState<int>, Option<String>), Set<FAState<int>>> transitionFunction = {
    (FAState(0), None()): {FAState(1), FAState(7)},
    (FAState(1), None()): {FAState(2), FAState(4)},
    (FAState(2), Some('a')): {FAState(3)},
    (FAState(3), None()): {FAState(6)},
    (FAState(4), Some('b')): {FAState(5)},
    (FAState(5), None()): {FAState(6)},
    (FAState(6), None()): {FAState(1), FAState(7)},
    (FAState(7), Some('a')): {FAState(8)},
  };

  final initialState = FAState(0);
  final finalStates = <FAState<int>>{FAState(8)};

  return NFA.createNFA(states, alphabet, transitionFunction, initialState, finalStates);
}

Either<String, NFA<String>> createNFA4() {
  final states = FAStateSet({FAState('q0'), FAState('q1'), FAState('q2'), FAState('q3'), FAState('q4')});
  final Set<String> alphabet = {'a', 'b'};

  final Map<(FAState<String>, Option<String>), Set<FAState<String>>> transitionFunction = {
    (FAState('q0'), Some('a')): {FAState('q1')},
    (FAState('q0'), None()): {FAState('q3')},
    (FAState('q1'), Some('b')): {FAState('q2')},
    for (var symbol in alphabet) (FAState('q3'), Some(symbol)): {FAState('q4')},
    for (var symbol in alphabet) (FAState('q2'), Some(symbol)): {FAState('q0')},
    (FAState('q4'), Some('b')): {FAState('q3')},
  };

  final initialState = FAState('q0');
  final finalStates = <FAState<String>>{FAState('q1'), FAState('q3')};

  return NFA.createNFA(states, alphabet, transitionFunction, initialState, finalStates);
}
