# Finite Automata Simulator

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Overview

The Finite Automata Simulator is a powerful tool designed to simulate Finite Automata and perform various operations on them. Whether you are a student studying automata theory or a researcher exploring the depths of computational models, this tool provides a user-friendly interface to visualize and analyze finite automata.

## Features

- **Simulation:** Simulate the behavior of a Finite Automaton with ease.
- **Machine Configuration:** Generate the machine configuration for a given input string.
- **Extended Transition Function:** Compute the extended transition function for a given Finite Automaton.
- **Step-by-Step Execution:** Understand the automaton's operation by stepping through each transition.

## Deterministic Finite Automaton (DFA)

A Deterministic Finite Automaton (DFA) is a theoretical concept in computer science and automata theory. It serves as a mathematical model representing a simple computational device or machine. DFAs belong to the broader category of finite automata, which are used to recognize patterns and structures in strings.

### Components of a DFA
A Deterministic Finite Automaton (DFA) is defiend as **M = (Q, Σ, δ, q0, F)**

1. **States (Q):** The DFA has a finite set of states, each representing a particular condition or situation the machine can be in at a given moment.

2. **Alphabet (Σ):** The finite set of symbols or characters that the DFA can read from an input string. For example, if working with binary strings, the alphabet would be {0, 1}.

3. **Transition Function (δ):** This function defines the behavior of the DFA, specifying, for each combination of a current state and an input symbol, the next state that the machine should transition to.

4. **Initial State (q0):** The starting state of the DFA, representing the state the machine is in before processing any input.

5. **Accepting States (F):** A subset of the set of states. If the DFA reaches a state in the accepting states set after processing the entire input string, then the input string is accepted.

7. **Input String:** The DFA processes an input string symbol by symbol, reading one symbol at a time and transitioning between states according to the transition function.

## Determinism

The key characteristic of a DFA is determinism, meaning that for each combination of a current state and an input symbol, there is exactly one next state. This property distinguishes DFAs from non-deterministic finite automata (NFAs), where multiple transitions can be possible for a given combination of state and input symbol.

## Applications

DFAs find applications in various areas of computer science, including lexical analysis in compiler design, pattern matching, and string processing. They are fundamental to understanding the concept of regular languages and regular expressions.


## Getting Started
To construct a DFA machine represented by  M(Q, Σ, δ, q0, F), utilize the static method `DFA.createDFA`. This method not only assembles the DFA components but also performs validation. Upon execution, it returns an Either object. If the result is of type Left, it signifies that the DFA is invalid, accompanied by a reason for the validation failure. Conversely, if the result is of type Right, it provides a valid DFA object. You can then leverage this object to execute various operations on the DFA.

For example the below DFA with Σ = {0, 1} accepts those strings which ends with 1.

M = ({q0, q1}, {0, 1}, δ, q0, {q1})
|  δ  |  0  |  1  |
| --- | --- | --- |
|  q0 |  q0 |  q1 |
|  q1 |  q0 |  q1 |


```dart
Either<String, DFA<String>> createDFA() {
  final states = {FAState('q0'), FAState('q1')};
  final binaryAlphabet = {'0', '1'};

  final DFATransitionFn<String> transitions = {
    (FAState('q0'), '0'): FAState('q0'),
    (FAState('q0'), '1'): FAState('q1'),
    (FAState('q1'), '0'): FAState('q0'),
    (FAState('q1'), '1'): FAState('q1'),
  };

  final initialState = FAState('q0');
  final finalStates = {FAState('q1')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, finalStates);
}
```


