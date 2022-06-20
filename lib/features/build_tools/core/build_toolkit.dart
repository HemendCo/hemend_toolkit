import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/android/build_configs/android_build_config.dart';
import 'package:yaml/yaml.dart';

import '../platforms/ios/build_configs/ios_build_config.dart';
import 'contracts/build_config/build_config.dart';

abstract class BuildToolkit {
  static String toAndroidOutputPath(String appName) => 'outputs/$appName.apk';
  static String _buildAppName({
    required String format,
    required String suffix,
  }) {
    String appName = format;
    final config = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;

    final dt = deInjector.get<DateTime>();
    appName = appName.replaceAll(r'$n%', config['name']);
    appName = appName.replaceAll(r'$v%', 'v.${config['version']}');

    appName = appName.replaceAll(r'$YYYY%', dt.year.toString());
    appName = appName.replaceAll(
      r'$YY',
      dt.year.toString().substring(2),
    );
    appName = appName.replaceAll(r'$MM%', dt.month.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$DD%', dt.day.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$HH%', dt.hour.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$mm%', dt.minute.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$ss%', dt.second.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$build_type%', suffix);
    final floatingInformations = deInjector.get<Map<String, String>>();
    for (final i in floatingInformations.entries) {
      appName = appName.replaceAll('\$${i.key}%', i.value);
    }

    return appName;
  }

  static Future<void> _buildCommand(IBuildConfig buildConfig) async {
    final params = await buildConfig.builderParams;

    final runResult = await cli.runTaskInTerminal(
      name: 'Building',
      command: buildConfig.builder,
      arguments: params,
    );

    if (runResult.exitCode != 0) {
      cli.printToConsole(
        'Build failed:\n${runResult.stdout}\n${runResult.stderr}',
        isError: true,
      );
      exit(runResult.exitCode);
    } else {
      cli.printToConsole('Build Done:\n${runResult.stdout}\n${runResult.stderr}');
      if (buildConfig is AndroidBuildConfig) {
        final finalApk = File(buildConfig.outputFileAddress);
        final String appName = _buildAppName(
          suffix: buildConfig.buildType.name,
          format: buildConfig.nameFormat,
        );
        final outputPath = toAndroidOutputPath(appName);
        finalApk.renameSync(outputPath);
        cli.printToConsole('Build output: $outputPath');
      }
      if (buildConfig is IosBuildConfig) {
        cli.printToConsole('Build output: ${buildConfig.outputFileAddress}');
      }
    }
  }

  static Future<void> build(IBuildConfig buildConfig) async {
    return _buildCommand(buildConfig);
  }
}
