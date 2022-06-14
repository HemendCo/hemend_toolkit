// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

import 'contracts/build_config/build_config.dart';

abstract class BuildToolkit {
  static Future<void> _buildCommand(BasicBuildConfig buildConfig) async {
    Process.run(
      buildConfig.builder,
      await buildConfig.builderParams,
    );
  }

  Future<void> build() async {
    CommandLineTools.instance.runAsyncOn('Building', () => _buildCommand(DeInject.get<BasicBuildConfig>()));
  }
}
