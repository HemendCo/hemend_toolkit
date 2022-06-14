abstract class DeInject {
  static Map<Type, dynamic> _dependencies = {};
  static void register<T>(T dependency) {
    _dependencies[T] = dependency;
  }

  static T get<T>() {
    final dep = _dependencies[T];
    if (dep is Function) {
      return dep();
    }
    return dep;
  }

  static void registerFactory<T>(T Function() factory) {
    _dependencies[T] = factory;
  }
}
