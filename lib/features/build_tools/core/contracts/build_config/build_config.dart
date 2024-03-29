// ignore_for_file: lines_longer_than_80_chars

import 'package:hemend_toolkit/features/product_config_toolkit/versioning/versioning.dart';
import 'package:meta/meta.dart';

import '../../../../../core/dependency_injector/basic_dependency_injector.dart';
import '../../build_toolkit.dart';
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
  String get nameFormat;

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

  BasicBuildConfig({required this.buildType});

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
        ...buildType.environmentParams,
        ...deInjector
            .get<Map<String, String>>()
            .map((key, value) => MapEntry(key.replaceAll(' ', '_'), value.replaceAll(' ', '_'))),
      };

  ///generated params from [environmentParams]
  Future<Iterable<String>> get _environments async => //
      (await environmentParams).entries.map(
            (e) => '--dart-define=${e.key}=${e.value}',
          );

  @override
  @mustCallSuper
  Future<List<String>> get builderParams async => [
        ...buildCommand,
        ...buildType.buildParams,
        ...await _environments,
      ];

  @override
  final BuildType buildType;

  @override
  String get outputFileAddress => 'build/';
}

abstract class ObfuscatedBuildConfig extends BasicBuildConfig {
  ObfuscatedBuildConfig({
    super.buildType = BuildType.release,
  });

  String get _obfuscationPath {
    final appName = BuildToolkit.buildAppName(
      suffix: buildType.name,
      format: nameFormat,
    );
    final buffer = StringBuffer()
      ..write('outputs/')
      ..write(appName);
    return buffer.toString();
  }

  List<String> get obfuscateParams => [
        '--obfuscate',
        '--split-debug-info=$_obfuscationPath/',
      ];
  @override
  Future<List<String>> get builderParams async => [
        ...await super.builderParams,
        ...obfuscateParams,
      ];

  @override
  String get outputFileAddress => 'build/';

  @override
  String get nameFormat;
}
