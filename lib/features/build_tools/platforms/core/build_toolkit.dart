import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

import '../../contracts/build_config/build_config.dart';

abstract class BuildToolkit {
  static Future<void> _buildCommand(IBuildConfig buildConfig) async {
    final runResult = await CLI.I.runTaskInTerminal(
      name: 'Building',
      command: buildConfig.builder,
      arguments: await buildConfig.builderParams,
    );
    if (runResult.exitCode != 0) {
      CLI.I.printToConsole('Build failed:\n${runResult.stdout}\n${runResult.stderr}');
      exit(runResult.exitCode);
    } else {
      CLI.I.printToConsole('Build Done:\n${runResult.stdout}\n${runResult.stderr}');
      exit(runResult.exitCode);
    }
  }

  static Future<void> build() async {
    return _buildCommand(DeInjector.get<IBuildConfig>());
  }
}
