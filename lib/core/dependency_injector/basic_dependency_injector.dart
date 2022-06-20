// typedef KeyValuePair = MapEntry<String, Type>;

abstract class DeInjector {
  static final Map<KeyValuePair, dynamic> _dependencies = {};
  static void register<T>(T dependency, [String instanceName = 'base']) {
    _dependencies[KeyValuePair(instanceName, T)] = dependency;
  }

  static Map<KeyValuePair, dynamic> get getAll => _dependencies;
  static T get<T>([String instanceName = 'base']) {
    final dep = _dependencies[KeyValuePair(instanceName, T)];
    if (dep is Function) {
      return dep();
    }
    return dep;
  }

  static void registerFactory<T>(T Function() factory, [String instanceName = 'base']) {
    _dependencies[KeyValuePair(instanceName, T)] = factory;
  }
}

class KeyValuePair {
  final String base;
  final Type pair;
  const KeyValuePair(this.base, this.pair);
  @override
  bool operator ==(Object? other) {
    if (other is KeyValuePair) {
      return base == other.base && pair == other.pair;
    }
    return false;
  }

  @override
  int get hashCode => base.hashCode ^ pair.hashCode;
}
