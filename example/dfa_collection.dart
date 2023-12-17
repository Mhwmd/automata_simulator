import 'package:automata_simulator/automata_simulator.dart';
import 'package:fpdart/fpdart.dart';

// DFA for accepting integer and float numbers without sign
Either<String, DFA<String>> createNumberDFA() {
  final states = {FAState('A'), FAState('B'), FAState('C'), FAState('D')};
  final digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
  final alphabet = {...digits, '.'};

  final DFATransitionFn<String> transitions = {
    for (var symbol in digits) (FAState('A'), symbol): FAState('B'),
    for (var symbol in digits) (FAState('B'), symbol): FAState('B'),
    (FAState('B'), '.'): FAState('C'),
    for (var symbol in digits) (FAState('C'), symbol): FAState('D'),
    for (var symbol in digits) (FAState('D'), symbol): FAState('D'),
  };

  final initialState = FAState('A');
  final acceptingStates = {FAState('B'), FAState('D')};

  return DFA.createDFA(states, alphabet, transitions, initialState, acceptingStates);
}

// DFA that accepts inputs where |w| mod 3 = 0 on alphabet {a, b}
Either<String, DFA<int>> createDivisibilityOfThreeDFA() {
  final states = {FAState(1), FAState(2), FAState(3)};
  final alphabet = {'a', 'b'};

  final DFATransitionFn<int> transitions = {
    for (var symbol in alphabet) (FAState(1), symbol): FAState(2),
    for (var symbol in alphabet) (FAState(2), symbol): FAState(3),
    for (var symbol in alphabet) (FAState(3), symbol): FAState(1),
  };

  final initialState = FAState(1);
  final acceptingStates = {FAState(1)};

  return DFA.createDFA(states, alphabet, transitions, initialState, acceptingStates);
}

// For example the below DFA with alphabet {0, 1} accepts those strings which ends with 1.
Either<String, DFA<String>> createBinaryNumberEndsWithOneDFA() {
  final states = {FAState('q0'), FAState('q1')};
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('q0'), '0'): FAState('q0'),
    (FAState('q0'), '1'): FAState('q1'),
    (FAState('q1'), '1'): FAState('q1'),
    (FAState('q1'), '0'): FAState('q0'),
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q1')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}

Either<String, DFA<String>> dfa1() {
  final states = {FAState('q0'), FAState('q1'), FAState('q2'), FAState('q3'), FAState('q4'), FAState('q5')};
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('q0'), '0'): FAState('q3'),
    (FAState('q0'), '1'): FAState('q1'),
    (FAState('q1'), '0'): FAState('q2'),
    (FAState('q1'), '1'): FAState('q5'),
    (FAState('q2'), '0'): FAState('q2'),
    (FAState('q2'), '1'): FAState('q5'),
    (FAState('q3'), '0'): FAState('q0'),
    (FAState('q3'), '1'): FAState('q4'),
    (FAState('q4'), '0'): FAState('q2'),
    (FAState('q4'), '1'): FAState('q5'),
    (FAState('q5'), '0'): FAState('q5'),
    (FAState('q5'), '1'): FAState('q5'),
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q4'), FAState('q2')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}

Either<String, DFA<String>> dfa2() {
  final states = {
    FAState('A'),
    FAState('B'),
    FAState('C'),
    FAState('D'),
    FAState('E'),
    FAState('F'),
    FAState('G'),
    FAState('H'),
  };
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('A'), '0'): FAState('B'),
    (FAState('A'), '1'): FAState('F'),
    (FAState('B'), '0'): FAState('G'),
    (FAState('B'), '1'): FAState('C'),
    (FAState('C'), '0'): FAState('A'),
    (FAState('C'), '1'): FAState('C'),
    (FAState('D'), '0'): FAState('C'),
    (FAState('D'), '1'): FAState('G'),
    (FAState('E'), '0'): FAState('H'),
    (FAState('E'), '1'): FAState('F'),
    (FAState('F'), '0'): FAState('C'),
    (FAState('F'), '1'): FAState('G'),
    (FAState('G'), '0'): FAState('G'),
    (FAState('G'), '1'): FAState('E'),
    (FAState('H'), '0'): FAState('G'),
    (FAState('H'), '1'): FAState('C'),
  };

  final initialState = FAState('A');
  final acceptingStates = {FAState('C')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}

Either<String, DFA<String>> dfa3() {
  final states = {
    FAState('q0'),
    FAState('q1'),
    FAState('q2'),
    FAState('q3'),
    FAState('q4'),
    FAState('q5'),
    FAState('q6'),
    FAState('q7'),
  };
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('q0'), '0'): FAState('q1'),
    (FAState('q0'), '1'): FAState('q5'),
    (FAState('q1'), '0'): FAState('q6'),
    (FAState('q1'), '1'): FAState('q2'),
    (FAState('q2'), '0'): FAState('q0'),
    (FAState('q2'), '1'): FAState('q2'),
    (FAState('q3'), '0'): FAState('q2'),
    (FAState('q3'), '1'): FAState('q6'),
    (FAState('q4'), '0'): FAState('q7'),
    (FAState('q4'), '1'): FAState('q5'),
    (FAState('q5'), '0'): FAState('q2'),
    (FAState('q5'), '1'): FAState('q6'),
    (FAState('q6'), '0'): FAState('q6'),
    (FAState('q6'), '1'): FAState('q4'),
    (FAState('q7'), '0'): FAState('q6'),
    (FAState('q7'), '1'): FAState('q2'),
  };

  final initialState = FAState('q0');
  final acceptingStates = {FAState('q2')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}

Either<String, DFA<String>> dfa4() {
  final states = {FAState('A'), FAState('B'), FAState('C'), FAState('D'), FAState('E')};
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('A'), '0'): FAState('B'),
    (FAState('A'), '1'): FAState('C'),
    (FAState('B'), '0'): FAState('B'),
    (FAState('B'), '1'): FAState('D'),
    (FAState('C'), '0'): FAState('B'),
    (FAState('C'), '1'): FAState('C'),
    (FAState('D'), '0'): FAState('B'),
    (FAState('D'), '1'): FAState('E'),
    (FAState('E'), '0'): FAState('B'),
    (FAState('E'), '1'): FAState('C'),
  };

  final initialState = FAState('A');
  final acceptingStates = {FAState('E')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}

Either<String, DFA<String>> dfa5() {
  final states = {
    FAState('A'),
    FAState('B'),
    FAState('C'),
    FAState('D'),
    FAState('E'),
    FAState('F'),
  };
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('A'), '0'): FAState('B'),
    (FAState('A'), '1'): FAState('C'),
    (FAState('B'), '0'): FAState('A'),
    (FAState('B'), '1'): FAState('D'),
    (FAState('C'), '0'): FAState('E'),
    (FAState('C'), '1'): FAState('F'),
    (FAState('D'), '0'): FAState('E'),
    (FAState('D'), '1'): FAState('F'),
    (FAState('E'), '0'): FAState('E'),
    (FAState('E'), '1'): FAState('F'),
    (FAState('F'), '0'): FAState('F'),
    (FAState('F'), '1'): FAState('F'),
  };

  final initialState = FAState('A');
  final acceptingStates = {FAState('C'), FAState('D'), FAState('E')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}
