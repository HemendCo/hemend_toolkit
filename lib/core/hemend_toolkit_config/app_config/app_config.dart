import 'dart:io';

import 'package:hemend_toolkit/features/build_tools/core/build_toolkit.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/ios/build_configs/ios_build_config.dart';
import 'package:hemend_toolkit/features/package_manager/pub.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/read_config/project_config_reader.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/sample_creator/product_config_sample_creator.dart';
import 'package:meta/meta.dart';

import '../../../features/build_tools/core/contracts/build_config/build_config.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../../../features/build_tools/platforms/android/build_configs/android_build_config.dart';
import '../../../features/product_config_toolkit/read_config/product_config_reader.dart';
import '../../io/command_line_toolkit/command_line_tools.dart';

void _checkPubspecYaml() {
  if (!ProjectConfigs.hasPubspec) {
    HemTerminal.I.printToConsole('Pubspec file not found.', isError: true);
    HemTerminal.I.printToConsole('run this command in root of the project');
    exit(64);
  }
}

void _checkHemspecYaml() {
  if (!ProjectConfigs.hasHemendspec) {
    HemTerminal.I.printToConsole('hemspec file not found.', isError: true);
    HemTerminal.I.printToConsole('run `hem init` in root of the project to create `hemspec.yaml` file');
    exit(64);
  }
}

abstract class IAppConfig {
  String get configName;
  final bool isForced;

  IAppConfig({required this.isForced});
  Future<void> _validate() async {}
  @mustCallSuper
  Future<void> validateAndInvoke() async {
    await _validate();
    await _invoke();
  }

  Future<void> _invoke();
  @override
  String toString() => configName;
}

class HemInstallAppConfig extends IAppConfig {
  HemInstallAppConfig({required super.isForced});

  @override
  Future<void> _invoke() async {
    final hemendAppFile = File(Platform.resolvedExecutable);
    if (Directory(r'c:\windows').existsSync()) {
      final hemendPath = r'C:\hemend';
      if (isForced || !File('$hemendPath\\hem.exe').existsSync()) {
        await hemendAppFile.copy(
          '$hemendPath\\hem.exe',
        );
        await HemTerminal.I.runTaskInTerminal(
          name: 'Setting path',
          command: 'setx',
          runInShell: true,
          arguments: [
            '/m',
            'PATH',
            '"$hemendPath;%PATH%"',
          ],
        );
      } else {
        HemTerminal.I.printToConsole(
            'hemend is already installed. to override this you need to run this command with --force(-f) option',
            isError: true);
      }
    } else {
      HemTerminal.I.printToConsole(
          'cannot install hem cli directly manually set an alias or add this directory to path.',
          isError: true);
    }
  }

  @override
  String get configName => 'Hemend Install';
}

class PubAppConfig extends IAppConfig {
  final bool shouldClean;
  final bool shouldUpgrade;
  PubAppConfig({
    required super.isForced,
    required this.shouldClean,
    required this.shouldUpgrade,
  });
  @override
  Future<void> _validate() async {
    _checkPubspecYaml();
    if (isForced) {
      HemTerminal.I.printToConsole(
        'executed with --force (-f) flag, this command has no force mode and flag will be ignored',
        isError: true,
      );
    }
  }

  @override
  Future<void> _invoke() async {
    if (shouldClean) {
      await PackageManager.pubClean();
    }
    if (shouldUpgrade) {
      await PackageManager.upgradePackages();
    }
    await PackageManager.pubGet();
  }

  @override
  String get configName => 'Flutter Package Manager';
}

class BuildAppConfig extends IAppConfig {
  final BuildPlatform platform;
  final BuildType buildType;
  @override
  Future<void> _validate() async {
    _checkPubspecYaml();
    _checkHemspecYaml();
    if (!ProjectConfigs.canBuildFor(platform)) {
      HemTerminal.I.printToConsole('cannot find directory for platform: ${platform.name}', isError: true);
      HemTerminal.I.printToConsole('run this command in root of the project');
      exit(64);
    }
  }

  // final Map<String, String> extraParams;
  BuildAppConfig({
    required this.platform,
    required this.buildType,
    required super.isForced,
    // required this.extraParams,
  });
  IBuildConfig get getBuildConfig {
    switch (platform) {
      case BuildPlatform.android:
        return AndroidBuildConfig(
          buildType: buildType,
          nameFormat: readHemendCliConfig()['HEMEND_CONFIG_NAME_FORMAT'] ?? 'error',
        );
      case BuildPlatform.ios:
        return IosBuildConfig(buildType: buildType);
      case BuildPlatform.windows:
        throw UnimplementedError();
      case BuildPlatform.linux:
        throw UnimplementedError();
      case BuildPlatform.web:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> _invoke() => BuildToolkit.build(getBuildConfig);

  @override
  String get configName => 'App Builder';
}

class InitializeAppConfig extends IAppConfig {
  InitializeAppConfig({
    required super.isForced,
  });
  @override
  Future<void> _validate() async {
    if (!ProjectConfigs.hasPubspec) {
      HemTerminal.I.printToConsole(
        'Pubspec file not found. cannot initialize hemend tools without pubspec file',
        isError: true,
      );
      HemTerminal.I.printToConsole('run this command in root of the project');
      exit(64);
    }
  }

  @override
  Future<void> _invoke() => ProductConfigSampleCreator.productConfigSampleCreator(isForced);

  @override
  String get configName => 'Hemend Core initializer';
}
