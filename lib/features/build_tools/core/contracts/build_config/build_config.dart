import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/features/git_toolkit/git_toolkit.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/read_config/product_config_reader.dart';
import 'package:meta/meta.dart';

import '../enums/build_mode.dart';
import '../typedefs/typedefs.dart';

abstract class IBuildConfig {
  String get outputFileAddress;

  ///base executable name in this case its flutter
  String get builder;

  ///build type will determine what kind of release will be built
  BuildType get buildType;

  ///basic build command to pass as first params to flutter
  List<String> get buildCommand;

  ///environments will be used for basic configuration and can be access with
  ///[String.fromEnvironment], [int.fromEnvironment] and [bool.fromEnvironment]
  ///you need to call [super.environment] to add default keys
  Future<EnvironmentParams> get environmentParams;

  ///final params that will be passed to [builder]
  Future<List<String>> get builderParams;
}

///this will generate the needed params for build task
abstract class BasicBuildConfig implements IBuildConfig {
  @override
  final String builder = 'flutter';

  @override
  @mustCallSuper
  List<String> get buildCommand => [
        'build',
      ];

  ///environments will be used for basic configuration and can be access with
  ///[String.fromEnvironment], [int.fromEnvironment] and [bool.fromEnvironment]
  ///in this class it will have some default keys like BUILD_TIME so on subclasses
  ///you need to call [super.environment] to add default keys
  @override
  @mustCallSuper
  Future<EnvironmentParams> get environmentParams async => {
        'BUILD_TIME': (deInjector.get<DateTime>().millisecondsSinceEpoch ~/ 1000).toString(),
        'LAST_GIT_COMMIT': await GitToolkit.getLastCommitsHash(),
        ...buildType.environmentParams,
        ...readProductConfig(),
      };

  ///generated params from [environmentParams]
  Future<Iterable<String>> get _environments async => (await environmentParams).entries.map(
        (e) => "--dart-define=${e.key}=${e.value}",
      );

  @override
  @mustCallSuper
  Future<List<String>> get builderParams async => [
        ...buildCommand,
        ...buildType.buildParams,
        ...(await _environments),
      ];
}

abstract class ObfuscatedBuildConfig extends BasicBuildConfig {
  String get _obfuscationPath {
    final currentDatTime = deInjector.get<DateTime>();
    final buffer = StringBuffer();
    buffer.write('symbols-');
    buffer.write(currentDatTime.year);
    buffer.write('-');
    buffer.write(currentDatTime.month);
    buffer.write('-');
    buffer.write(currentDatTime.day);
    buffer.write('[');
    buffer.write(currentDatTime.hour);
    buffer.write(':');
    buffer.write(currentDatTime.minute);
    buffer.write(']');
    return buffer.toString();
  }

  List<String> get obfuscateParams => [
        '--obfuscate',
        '--split-debug-info=$_obfuscationPath/',
      ];
  @override
  Future<List<String>> get builderParams async => [
        ...(await super.builderParams),
        ...obfuscateParams,
      ];
}
