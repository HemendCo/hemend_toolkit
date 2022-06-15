import 'dart:io';

import 'package:args/args.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../app_config/app_config.dart';

abstract class AppConfigParser {
  static final _parser = ArgParser();
  static Future<IAppConfig> parsAndRun(List<String> args) async {
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
    _parser.addFlag(
      'force',
      abbr: 'f',
      defaultsTo: false,
    );
    _parser.addCommand('build', buildCommandParser);
    _parser.addCommand(
      'init',
    );

    final parserResult = _parser.parse(args);
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
          return BuildAppConfig(
            platform: buildPlatform,
            buildType: BuildType.fromString(
              buildCommand.command?['mode'] ?? BuildType.release.name,
            ),
            isForced: parserResult['force'],
          );
        } catch (e) {
          print('No build option provided');
          exit(64);
        }

      case 'init':
        // HemTerminal.I.printToConsole('initializing hemend core tools');
        return InitializeAppConfig(
          isForced: parserResult['force'],
        );
    }
    print('''Unknown command: ${parserResult.rest.first}
known commands are:
  init
  build
  pub
''');
    exit(64);
  }
}
