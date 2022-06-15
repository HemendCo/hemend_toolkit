import 'dart:io';

import 'package:args/args.dart';
import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/sample_creator/product_config_sample_creator.dart';

import '../../../features/build_tools/core/build_toolkit.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../app_config/app_config.dart';

class AppConfigParser {
  ArgParser parser = ArgParser();
  AppConfigParser(List<String> args) {
    final buildModeParser = ArgParser()
      ..addOption(
        'mode',
        abbr: 'm',
        defaultsTo: BuildType.release.name,
        allowed: BuildType.values.map((e) => e.name),
        help: 'With this parameter you can set build mode',
      );

    final buildCommandParser = ArgParser()
      ..addCommand(
        'apk',
        buildModeParser,
      )
      ..addCommand(
        'ios',
        buildModeParser,
      );

    parser.addCommand('build', buildCommandParser);
    parser.addCommand(
      'init',
    );

    final parserResult = parser.parse(args);
    if (parserResult.rest.isNotEmpty) {
      print('Unknown command: ${parserResult.rest.first}');
      exit(64);
    }
    switch (parserResult.command?.name) {
      case 'build':
        final buildCommand = parserResult.command!;
        try {
          final buildPlatform = BuildPlatform.fromString(
            buildCommand.command?.name,
          );
          DeInjector.register(
            BuildAppConfig(
              buildPlatform,
              BuildType.fromString(
                buildCommand.command?['mode'] ?? BuildType.release.name,
              ),
            ).getBuildConfig,
          );
          BuildToolkit.build();
        } catch (e) {
          print('No build option provided');
          exit(64);
        }
        break;
      case 'init':
        HemTerminal.I.printToConsole('initializing hemend core tools');
        productConfigSampleCreator();
        break;
      default:
        print('''Unknown command: ${parserResult.rest.first}
known commands are:
  build
''');
        exit(64);
    }
  }
}
