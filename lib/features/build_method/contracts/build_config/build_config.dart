import 'package:meta/meta.dart';

abstract class IBuildConfig {
  ///base executable name in this case its flutter
  String get builder;

  ///basic build command to pass as first params to flutter
  List<String> get buildCommand;

  ///environments will be used for basic configuration and can be access with
  ///[String.fromEnvironment], [int.fromEnvironment] and [bool.fromEnvironment]
  ///you need to call [super.environment] to add default keys
  Map<String, String> get environmentParams;

  ///final params that will be passed to [builder]
  Future<List<String>> get builderParams;
}

///this will generate the needed params for build task
abstract class BasicBuildConfig implements IBuildConfig {
  ///base executable name in this case its flutter
  @override
  final String builder = 'flutter';

  ///basic build command to pass as first params to flutter
  @override
  List<String> get buildCommand => [
        'build',
      ];

  ///environments will be used for basic configuration and can be access with
  ///[String.fromEnvironment], [int.fromEnvironment] and [bool.fromEnvironment]
  ///in this class it will have some default keys like BUILD_TIME so on subclasses
  ///you need to call [super.environment] to add default keys
  @override
  @mustCallSuper
  Map<String, String> get environmentParams => {
        'BUILD_TIME': (DateTime.now().millisecondsSinceEpoch / 1000).toString(),
      };

  ///generated params from [environmentParams]
  Iterable<String> get _environments => environmentParams.entries.map(
        (e) => "--dart-define=${e.key}=${e.value}",
      );

  @override
  @mustCallSuper
  Future<List<String>> get builderParams async => [
        ...buildCommand,
        ..._environments,
      ];
}

abstract class ObfuscatedBuildConfig extends BasicBuildConfig {
  List<String> get obfuscateParams => [
        '--obfuscate',

        ///get from params
        '--split-debug-info=symbols/',
      ];
  @override
  Future<List<String>> get builderParams async => [
        ...(await super.builderParams),
        ...obfuscateParams,
      ];
}
