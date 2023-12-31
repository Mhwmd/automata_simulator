import 'package:automata_simulator/automata_simulator.dart';
import 'package:fpdart/fpdart.dart';

Either<String, NFA<String>> createNFA1() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2')};
  final alphabet = {'a', 'b'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), Some('a')): {FAState('q0')},
    (FAState('q0'), Some('b')): {FAState('q0'), FAState('q1')},
    (FAState('q1'), Some('b')): {FAState('q2')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q2')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
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

  final alphabet = {'a', 'b'};

  final NFATransitionFn<int> transitions = {
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
  final acceptingStates = {FAState(10)};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
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

  final NFATransitionFn<int> transitions = {
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
  final acceptingStates = {FAState(8)};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA4() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2'), FAState('q3'), FAState('q4')};
  final Set<String> alphabet = {'a', 'b'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), Some('a')): {FAState('q1')},
    (FAState('q0'), None()): {FAState('q3')},
    (FAState('q1'), Some('b')): {FAState('q2')},
    for (var symbol in alphabet) (FAState('q3'), Some(symbol)): {FAState('q4')},
    for (var symbol in alphabet) (FAState('q2'), Some(symbol)): {FAState('q0')},
    (FAState('q4'), Some('b')): {FAState('q3')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q1'), FAState('q3')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA5() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2')};
  final Set<String> alphabet = {'0', '1', '2'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), Some('0')): {FAState('q0')},
    (FAState('q0'), None()): {FAState('q1')},
    (FAState('q1'), Some('1')): {FAState('q1')},
    (FAState('q1'), None()): {FAState('q2')},
    (FAState('q2'), Some('2')): {FAState('q2')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q2')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA6() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2')};
  final Set<String> alphabet = {'a', 'b'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), Some('a')): {FAState('q1')},
    (FAState('q1'), None()): {FAState('q2')},
    (FAState('q2'), Some('b')): {FAState('q2')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q2')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA7() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2'), FAState('q3'), FAState('q4'), FAState('q5')};
  final Set<String> alphabet = {'a', 'b'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), None()): {FAState('q1')},
    (FAState('q0'), Some('b')): {FAState('q3')},
    (FAState('q1'), None()): {FAState('q2')},
    (FAState('q1'), Some('a')): {FAState('q3')},
    (FAState('q2'), Some('a')): {FAState('q4')},
    (FAState('q3'), None()): {FAState('q2')},
    (FAState('q3'), Some('b')): {FAState('q5')},
    (FAState('q4'), Some('b')): {FAState('q3')},
    (FAState('q4'), Some('a')): {FAState('q5')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q5')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA8() {
  final states = {
    FAState('q1'),
    FAState('q2'),
    FAState('q3'),
    FAState('q4'),
    FAState('q5'),
    FAState('q6'),
    FAState('q7'),
    FAState('q8'),
  };
  final Set<String> alphabet = {'A', 'C', 'G', 'T'};

  final NFATransitionFn<String> transitions = {
    (FAState('q1'), Some('A')): {FAState('q7')},
    (FAState('q1'), Some('T')): {FAState('q4')},
    (FAState('q1'), Some('C')): {FAState('q4')},
    (FAState('q1'), Some('G')): {FAState('q7'), FAState('q2'), FAState('q4')},
    //
    (FAState('q2'), Some('A')): {FAState('q3'), FAState('q6')},
    (FAState('q2'), Some('T')): {FAState('q6')},
    (FAState('q2'), Some('C')): {FAState('q2'), FAState('q4')},
    (FAState('q2'), Some('G')): {FAState('q3'), FAState('q6')},
    //
    (FAState('q3'), Some('A')): {FAState('q8')},
    (FAState('q3'), Some('T')): {FAState('q8')},
    (FAState('q3'), Some('C')): {FAState('q8')},
    //
    (FAState('q4'), Some('A')): {FAState('q5'), FAState('q8')},
    (FAState('q4'), Some('T')): {FAState('q2'), FAState('q4'), FAState('q5'), FAState('q8')},
    (FAState('q4'), Some('C')): {FAState('q4'), FAState('q8')},
    (FAState('q4'), Some('G')): {FAState('q5'), FAState('q8')},
    //
    (FAState('q5'), Some('A')): {FAState('q3'), FAState('q8')},
    (FAState('q5'), Some('T')): {FAState('q3'), FAState('q8')},
    (FAState('q5'), Some('C')): {FAState('q3'), FAState('q8')},
    (FAState('q5'), Some('G')): {FAState('q8')},
    //
    (FAState('q6'), Some('A')): {FAState('q8')},
    (FAState('q6'), Some('T')): {FAState('q8')},
    (FAState('q6'), Some('C')): {FAState('q8')},
    (FAState('q6'), Some('G')): {FAState('q8')},
    //
    (FAState('q7'), Some('A')): {FAState('q7'), FAState('q8')},
    (FAState('q7'), Some('T')): {FAState('q3'), FAState('q8')},
    (FAState('q7'), Some('C')): {FAState('q7'), FAState('q8')},
    (FAState('q7'), Some('G')): {FAState('q8')},
  };

  final initialState = FAState('q1');
  final acceptingStates = {FAState('q8')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}

Either<String, NFA<String>> createNFA9() {
  final states = {
    FAState('q0'),
    FAState('q1'),
    FAState('q2'),
    FAState('q3'),
    FAState('q4'),
    FAState('q5'),
    FAState('q6'),
    FAState('q7'),
    FAState('q8'),
  };
  final Set<String> alphabet = {'a', 'b'};

  final NFATransitionFn<String> transitions = {
    (FAState('q0'), None()): {FAState('q1')},
    (FAState('q1'), None()): {FAState('q2'), FAState('q6')},
    (FAState('q2'), Some('a')): {FAState('q3')},
    (FAState('q3'), None()): {FAState('q4')},
    (FAState('q4'), Some('b')): {FAState('q5')},
    (FAState('q5'), None()): {FAState('q1')},
    (FAState('q6'), Some('a')): {FAState('q7')},
    (FAState('q7'), None()): {FAState('q1')},
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q0'), FAState('q5'), FAState('q7')};

  return NFA.createNFA(states, alphabet, transitions, initialState, acceptingStates);
}
