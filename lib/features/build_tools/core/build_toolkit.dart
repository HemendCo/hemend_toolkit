import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

import 'contracts/build_config/build_config.dart';

abstract class BuildToolkit {
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
      //TODO handle apk file name

    }
  }

  static Future<void> build(IBuildConfig buildConfig) async {
    return _buildCommand(buildConfig);
  }
}
