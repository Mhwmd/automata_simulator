import 'package:equatable/equatable.dart';

class FAState<T> extends Equatable {
  FAState(this.name);

  final T name;

  @override
  List<Object?> get props => [name];
}
