/// create an instance of [_DeInjector]
final deInjector = _DeInjector();

/// basic dependency injector
class _DeInjector {
  /// instance of dependencies with a (key-value pair) as key
  /// that holds the dependency type and the dependency instance name
  /// and point them to the instance of the dependency
  final Map<_InjectorKey, dynamic> _dependencies = {};
  _DeInjector();
  static const _baseInstanceName = '';

  /// register a singleton dependency
  void register<T>(T dependency, [String instanceName = _baseInstanceName]) {
    _dependencies[_InjectorKey(instanceName, T)] = dependency;
  }

  /// register a factory for a dependency
  void registerFactory<T>(T Function() factory, [String instanceName = _baseInstanceName]) {
    _dependencies[_InjectorKey(instanceName, T)] = factory;
  }

  /// get the dependency instance of the type [T] with instance name of [instanceName]
  T get<T>([String instanceName = _baseInstanceName]) {
    final dep = _dependencies[_InjectorKey(instanceName, T)];
    if (dep is Function) {
      final value = dep();
      if (value is! T) {
        throw Exception('Dependency is not of type ${T.toString()}');
      }
      return value;
    }
    if (dep is! T) {
      throw Exception('Dependency is not of type ${T.toString()}');
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
