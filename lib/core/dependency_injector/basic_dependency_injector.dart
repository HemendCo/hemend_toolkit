/// create an instance of [DeInjector] at runtime
/// to avoid static initialization
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes, avoid_dynamic_calls, lines_longer_than_80_chars

// ignore: prefer_const_constructors
final deInjector = DeInjector._({});

/// basic dependency injector
class DeInjector {
  /// instance of dependencies with a (key-value pair) as key
  /// that holds the dependency type and the dependency instance name
  /// and point them to the instance of the dependency
  final Map<_InjectorKey, dynamic> _dependencies;
  const DeInjector._(this._dependencies);
  static const _baseInstanceName = '';

  /// register a singleton dependency
  void register<T>(
    T dependency, [
    String instanceName = _baseInstanceName,
  ]) {
    _dependencies[_InjectorKey(instanceName, T)] = dependency;
  }

  /// register a factory for a dependency
  void registerFactory<T>(
    T Function() factory, [
    String instanceName = _baseInstanceName,
  ]) {
    _dependencies[_InjectorKey(instanceName, T)] = factory;
  }

  /// get the dependency instance of the type [T]
  /// with instance name of [instanceName]
  T get<T>([
    String instanceName = _baseInstanceName,
  ]) {
    final dep = _dependencies[_InjectorKey(instanceName, T)];
    if (dep is Function) {
      final value = dep();
      if (value is! T) {
        throw Exception('no dependency for type: ${T.toString()}');
      }
      return value;
    }
    if (dep is! T) {
      throw Exception('no dependency for type: ${T.toString()}');
    }
    return dep;
  }

  T? getSafe<T>([
    String instanceName = _baseInstanceName,
  ]) {
    final dep = _dependencies[_InjectorKey(instanceName, T)];
    if (dep is Function) {
      final value = dep();
      if (value is! T) {
        return null;
      }
      return value;
    }
    if (dep is! T) {
      return null;
    }
    return dep;
  }
}

class _InjectorKey {
  final String base;
  final Type pair;
  const _InjectorKey(this.base, this.pair);
  @override
  bool operator ==(Object? other) {
    if (other is _InjectorKey) {
      return base == other.base && pair == other.pair;
    }
    return false;
  }

  @override
  int get hashCode => base.hashCode ^ pair.hashCode;
}
