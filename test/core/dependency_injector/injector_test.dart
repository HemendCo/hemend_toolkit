import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:test/test.dart';

void main() {
  test('deInjector test', () {
    deInjector.register('String mamad');
    expect(deInjector.get<String>(), 'String mamad');

    expect(deInjector.get<double>(), throwsA(isA<Exception>()));
  });
}
