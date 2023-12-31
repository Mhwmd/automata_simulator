import 'machine_configuration.dart';

class ComputationTree<StateType> {
  const ComputationTree(
    this.machineConfiguration, {
    required this.id,
    required this.depth,
    this.children = const [],
  });

  final int id;
  final int depth;
  final MachineConfiguration<StateType> machineConfiguration;
  final List<ComputationTree<StateType>> children;

  bool get isLeaf => children.isEmpty;
}
