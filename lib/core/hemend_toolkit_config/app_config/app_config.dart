import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config_parser/app_config_parser.dart';
import 'package:hemend_toolkit/features/build_tools/core/build_toolkit.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/sample_creator/product_config_sample_creator.dart';

import '../../../features/build_tools/core/contracts/build_config/build_config.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../../../features/build_tools/platforms/android/build_configs/android_build_config.dart';

abstract class IAppConfig {
  String get configName;
  final bool isForced;

  IAppConfig({required this.isForced});
  Future<void> run();
  @override
  String toString() => configName;
}

class PubAppConfig extends IAppConfig {
  PubAppConfig({
    required super.isForced,
  });

  @override
  Future<void> run() {
    // TODO: implement run
    throw UnimplementedError();
  }

  @override
  String get configName => 'Flutter Package Manager';
}

class BuildAppConfig extends IAppConfig {
  final BuildPlatform platform;
  final BuildType buildType;

  BuildAppConfig({
    required this.platform,
    required this.buildType,
    required super.isForced,
  });
  IBuildConfig get getBuildConfig {
    switch (platform) {
      case BuildPlatform.android:
        return AndroidBuildConfig(buildType: buildType);
      case BuildPlatform.ios:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> run() => BuildToolkit.build(getBuildConfig);

  @override
  String get configName => 'App Builder';
}

class InitializeAppConfig extends IAppConfig {
  InitializeAppConfig({
    required super.isForced,
  });

  @override
  Future<void> run() => ProductConfigSampleCreator.productConfigSampleCreator(isForced);

  @override
  String get configName => 'Hemend Core initializer';
}
