import 'dart:io';

import 'package:args/args.dart';
import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/hemend_toolkit_config/cli_config.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../app_config/app_config.dart';

abstract class AppConfigParser {
  static final _parser = ArgParser();
  static Future<IAppConfig> parsAndRun(List<String> args) async {
    final buildCommandParser = ArgParser()
      ..addOption(
        'mode',
        abbr: 'm',
        defaultsTo: BuildType.release.name,
        allowed: BuildType.values.map((e) => e.name),
        help: 'With this parameter you can set build mode',
      )
      ..addCommand(
        'apk',
      )
      ..addCommand(
        'ios',
      );

    final packageMangerConfigParser = ArgParser()
      ..addFlag(
        'clean',
        abbr: 'c',
        help: 'run flutter clean before pub get',
        defaultsTo: false,
      )
      ..addFlag(
        'upgrade',
        abbr: 'u',
        help: 'run pub upgrade to upgrade projects dependencies',
        defaultsTo: false,
      );

    _parser
      ..addFlag(
        'force',
        abbr: 'f',
        defaultsTo: false,
        help: '''run commands in unsafe mode (without validation, warnings, etc) 
  in this mode hem will override existing files like hemspec.yaml, pubspec.yaml, etc''',
      )
      ..addFlag(
        'verbos',
        abbr: 'v',
        help: 'run commands in verbose mode will print all commands and their output',
        defaultsTo: false,
      )
      ..addFlag(
        'online',
        abbr: 'o',
        help: '''uses hemend cli tool in online mode (currently not implemented)
  the default is offline mode
  in online mode will upload build result files and will init `Crashlytix` automatically
  and check for updates''',
        defaultsTo: false,
      )
      ..addCommand(
        'env',
      )
      ..addCommand(
        'init',
      )
      ..addCommand(
        'install',
      )
      ..addCommand(
        'get',
        packageMangerConfigParser,
      )
      ..addCommand(
        'build',
        buildCommandParser,
      );

    final parserResult = _parser.parse(args);
    if (parserResult.rest.isNotEmpty) {
      showHelp(parserResult.rest.isNotEmpty ? parserResult.rest.first : 'help');
    }
    final config = HemConfig(parserResult['verbos']);
    deInjector.register(config);
    if (config.verbos) {
      cli.useVerbosLogger();
    }
    try {
      deInjector.get<Map<String, String>>().addAll({'IS_FORCED': parserResult['force'].toString()});
      switch (parserResult.command?.name) {
        case 'env':
          final buildType = BuildType.fromString(
            BuildType.release.name,
          );
          deInjector.get<Map<String, String>>().addAll({'BUILD_MODE': buildType.name});
          deInjector.get<Map<String, String>>().addAll(buildType.environmentParams);
          deInjector.get<Map<String, String>>().addAll({'PLATFORM': 'android'});
          return VariableCheckConfig(isForced: false);
        case 'install':
          return HemInstallAppConfig(
            isForced: parserResult['force'],
          );
        case 'build':
          final buildCommand = parserResult.command!;
          final buildPlatform = BuildPlatform.fromString(
            buildCommand.command?.name,
          );
          final buildType = BuildType.fromString(
            buildCommand['mode'] ?? BuildType.release.name,
          );
          deInjector.get<Map<String, String>>().addAll({'BUILD_MODE': buildType.name});
          deInjector.get<Map<String, String>>().addAll(buildType.environmentParams);
          deInjector.get<Map<String, String>>().addAll({'PLATFORM': buildPlatform.name});
          return BuildAppConfig(
            platform: buildPlatform,
            buildType: buildType,
            isForced: parserResult['force'],
          );

        case 'get':
          deInjector.get<Map<String, String>>().addAll({'CLEAN': (parserResult.command?['clean']).toString()});
          deInjector.get<Map<String, String>>().addAll({'UPGRADE': (parserResult.command?['upgrade']).toString()});
          return PubAppConfig(
            isForced: parserResult['force'],
            shouldClean: parserResult.command?['clean'],
            shouldUpgrade: parserResult.command?['upgrade'],
          );
        case 'init':
          return InitializeAppConfig(
            isForced: parserResult['force'],
          );
        default:
          showHelp();
      }
    } on Exception catch (e) {
      cli.printToConsole(
        'cannot parse command: $e',
        isError: true,
      );
      showHelp();
    }
  }

  static Never showHelp([String? unknownCmd]) {
    final uses = dissolveHelpCommand(_parser.commands);
    if (unknownCmd != null && unknownCmd != 'help') {
      cli.printToConsole('Unknown command: $unknownCmd');
    }
    cli.printToConsole(
      '''known commands are:
${_parser.usage}
$uses
''',
      isError: false,
    );
    exit(64);
  }

  static String stager = '  ';
  static String dissolveHelpCommand(Map<String, ArgParser> commands, [String spacer = '']) {
    if (commands.isEmpty) {
      return '';
    }

    return commands.entries
        .map((e) => '$spacer${e.key}\n$stager$spacer${e.value.usage.replaceAll(
              '\n',
              '\n$stager$spacer',
            )}\n${dissolveHelpCommand(
              e.value.commands,
              stager,
            )}')
        .join('\n');
  }
}
