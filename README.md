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
A Deterministic Finite Automaton (DFA) is defined as **M = (Q, Σ, δ, q0, F)**

1. **States (Q):** The DFA has a finite set of states, each representing a particular condition or situation the machine can be in at a given moment.

2. **Alphabet (Σ):** The finite set of symbols or characters that the DFA can read from an input string. For example, if working with binary strings, the alphabet would be {0, 1}.

3. **Transition Function (δ):** This function defines the behavior of the DFA, specifying, for each combination of a current state and an input symbol, the next state that the machine should transition to.

4. **Initial State (q0):** The starting state of the DFA, representing the state the machine is in before processing any input.

5. **Accepting States (F):** A subset of the set of states. If the DFA reaches a state in the accepting states set after processing the entire input string, then the input string is accepted.

**Input String:** The DFA processes an input string symbol by symbol, reading one symbol at a time and transitioning between states according to the transition function.

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
  final acceptingStates = {FAState('q1')};

  return DFA.createDFA(states, binaryAlphabet, transitions, initialState, acceptingStates);
}
```
# Checking input accepted by DFA

```dart
  //..
  final inputString = '1001;
  final isAccepted =  dfa.isAccepted(inputString);
  print(isAccepted);
```


# Machine configuration
You can generate machine configuration of the DFA for the input string with method `DFA.generateMachineConfiguration`

```dart
  //..
  final inputString = '1001;
  final machineConfiguration =  dfa.generateMachineConfiguration(inputString);
  print(machineConfiguration);
```
Which for the above DFA machine configuration is 
```
[q0, 1001]|-[q1, 001]|-[q0, 01]|-[q0, 1]|-[q1, ε]
```

# Extended Transition Function
You can generate steps of the extended transition function of the DFA for the input string with method `DFA.generateExtendedTransitionSteps`

Which for the above DFA with input string of 1001 extended transition function steps are
```
δ^(q0, 1001)
 = δ^(δ(q0, 1), 001) => δ^(q1, 001)
 = δ^(δ(q1, 0), 01) => δ^(q0, 01)
 = δ^(δ(q0, 0), 1) => δ^(q0, 1)
 = δ(q0, 1) = q1
```

#
Some reports generated for DFA that only accepts unsigned integer and float numbers in the examples folder called `createNumberDFA()` for inputs `451.2351`, `145.`, `12ah` and `1001`

```
==============================
Input: 451.2351
==============================
Accepted: true
Machine Configuration: [A, 451.2351]|-[B, 51.2351]|-[B, 1.2351]|-[B, .2351]|-[C, 2351]|-[D, 351]|-[D, 51]|-[D, 1]|-[D, ε]
Extended Function: δ^(A, 451.2351)
 = δ^(δ(A, 4), 51.2351) => δ^(B, 51.2351)
 = δ^(δ(B, 5), 1.2351) => δ^(B, 1.2351)
 = δ^(δ(B, 1), .2351) => δ^(B, .2351)
 = δ^(δ(B, .), 2351) => δ^(C, 2351)
 = δ^(δ(C, 2), 351) => δ^(D, 351)
 = δ^(δ(D, 3), 51) => δ^(D, 51)
 = δ^(δ(D, 5), 1) => δ^(D, 1)
 = δ(D, 1) = D

Accepting States are: B, D

==============================
Input: 145.
==============================
Accepted: false
Machine Configuration: [A, 145.]|-[B, 45.]|-[B, 5.]|-[B, .]|-[C, ε]
Extended Function: δ^(A, 145.)
 = δ^(δ(A, 1), 45.) => δ^(B, 45.)
 = δ^(δ(B, 4), 5.) => δ^(B, 5.)
 = δ^(δ(B, 5), .) => δ^(B, .)
 = δ(B, .) = C

Accepting States are: B, D

==============================
Input: 12ah
==============================
Accepted: false
Machine Configuration: [A, 12ah]|-[B, 2ah]|-[B, ah]
Extended Function: δ^(A, 12ah)
 = δ^(δ(A, 1), 2ah) => δ^(B, 2ah)
 = δ^(δ(B, 2), ah) => δ^(B, ah)
 = δ^(δ(B, a), h)

Accepting States are: B, D

==============================
Input: 1001
==============================
Accepted: true
Machine Configuration: [A, 1001]|-[B, 001]|-[B, 01]|-[B, 1]|-[B, ε]
Extended Function: δ^(A, 1001)
 = δ^(δ(A, 1), 001) => δ^(B, 001)
 = δ^(δ(B, 0), 01) => δ^(B, 01)
 = δ^(δ(B, 0), 1) => δ^(B, 1)
 = δ(B, 1) = B

Accepting States are: B, D

```
