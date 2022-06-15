import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:yaml/yaml.dart';

import 'contracts/build_config/build_config.dart';

abstract class BuildToolkit {
  static const kDefaultApkOutput = 'build/app/outputs/flutter-apk/app-release.apk';
  static String _buildAppName(String suffix) {
    final config = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final buffer = StringBuffer();
    buffer.write(config['name']);
    buffer.write('-v.');
    buffer.write(config['version']);
    buffer.write('-');
    buffer.write(suffix);
    buffer.write('-');
    final dt = DeInjector.get<DateTime>().toIso8601String();
    buffer.write(dt.substring(0, dt.lastIndexOf('.')));

    return buffer.toString();
  }

  static Future<void> _buildCommand(IBuildConfig buildConfig) async {
    final params = await buildConfig.builderParams;

    final runResult = await HemTerminal.I.runTaskInTerminal(
      name: 'Building',
      command: buildConfig.builder,
      arguments: params,
    );
    if (runResult.exitCode != 0) {
      HemTerminal.I.printToConsole('Build failed:\n${runResult.stdout}\n${runResult.stderr}');
      exit(runResult.exitCode);
    } else {
      HemTerminal.I.printToConsole('Build Done:\n${runResult.stdout}\n${runResult.stderr}');

      final finalApk = File(kDefaultApkOutput);
      final String appName = _buildAppName(buildConfig.buildType.name);
      finalApk.renameSync('outputs/$appName.apk');
      HemTerminal.I.printToConsole('Build output: outputs/$appName.apk');
    }
  }

  static Future<void> build(IBuildConfig buildConfig) async {
    return _buildCommand(buildConfig);
  }
}
