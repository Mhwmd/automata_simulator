import 'dart:collection';

import 'package:equatable/equatable.dart';

class EquatableSet<T> extends SetBase<T> with EquatableMixin {
  EquatableSet(this._base);

  final Set<T> _base;

  @override
  bool add(T value) => _base.add(value);

  @override
  Set<T> difference(Set<Object?> other) => _base.difference(other);

  @override
  Set<T> intersection(Set<Object?> other) => _base.intersection(other);

  @override
  Set<T> union(Set<T> other) => _base.union(other);

  @override
  bool contains(Object? element) => _base.contains(element);

  @override
  Iterator<T> get iterator => _base.iterator;

  @override
  int get length => _base.length;

  @override
  T? lookup(Object? element) => _base.lookup(element);

  @override
  bool remove(Object? value) => _base.remove(value);

  @override
  Set<T> toSet() => EquatableSet(_base);

  @override
  List<Object?> get props => [_base];

  @override
  String toString() => _base.toString();
}

class EquatableList<T> extends ListBase<T> with EquatableMixin {
  const EquatableList(this._base);

  final List<T> _base;

  @override
  T operator [](int index) => _base[index];

  @override
  void operator []=(int index, T value) => _base[index] = value;

  @override
  set length(int newLength) => _base.length = newLength;

  @override
  int get length => _base.length;

  @override
  List<Object?> get props => [_base];

  @override
  String toString() => _base.toString();
}

extension ImmutableMap<K, V> on Map<K, V> {
  Map<K, V> immutableUpdate(K key, V Function(V value) update, {required V Function() ifAbsent}) {
    final newMap = Map<K, V>.from(this);
    newMap.update(key, update, ifAbsent: ifAbsent);

    return newMap;
  }
}
