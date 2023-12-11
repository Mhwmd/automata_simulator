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
