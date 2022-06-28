// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:args/args.dart';

import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../../dependency_injector/basic_dependency_injector.dart';
import '../../io/command_line_toolkit/command_line_tools.dart';
import '../app_config/app_config.dart';
import '../cli_config.dart';

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
      ..addOption(
        'output-type',
        abbr: 't',
        defaultsTo: 'apk',
        allowed: [
          'apk',
          'aab',
          'ios',
          'ipa',
        ],
        help: 'With this parameter you can set output of build method',
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
      )
      ..addFlag(
        'upgrade',
        abbr: 'u',
        help: 'run pub upgrade to upgrade projects dependencies',
      );

    _parser
      ..addMultiOption(
        'extra-arg',
        help: '''Add extra args to environments map the env parser will use them in its queries''',
        abbr: 'e',
        valueHelp: 'key=value,key2=value2',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: '''run commands in unsafe mode (without validation, warnings, etc) 
  in this mode hem will override existing files like hemspec.yaml, pubspec.yaml, etc''',
      )
      ..addFlag(
        'verbos',
        abbr: 'v',
        help: '''run commands in verbose mode will print all commands and their output''',
      )
      ..addFlag(
        'online',
        abbr: 'o',
        help: '''uses hemend cli tool in online mode (currently not implemented)
  the default is offline mode
  in online mode will upload build result files and will init `Crashlytix` automatically
  and check for updates''',
      )
      ..addCommand(
        'env',
        ArgParser()
          ..addFlag(
            'generate',
            abbr: 'g',
            help: 'Generate a Dart file for constant values',
          ),
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
      )
      ..addCommand(
        'builder',
        ArgParser()
          ..addFlag(
            'clean',
            abbr: 'c',
            help: 'use build runner with --delete-conflicting-outputs',
            defaultsTo: true,
          )
          ..addFlag(
            'watch',
            abbr: 'w',
            help: 'use build runner in watch mode',
          ),
      );

    final parserResult = _parser.parse(args);
    if (parserResult.rest.isNotEmpty) {
      showHelp(parserResult.rest.isNotEmpty ? parserResult.rest.first : 'help');
    }
    final config = HemConfig(
      verbose: parserResult['verbos'],
      isOnline: parserResult['online'],
    );
    deInjector.register(config);
    if (config.verbose) {
      cli.useVerbosLogger();
    }
    try {
      deInjector.get<Map<String, String>>().addAll({'IS_FORCED': parserResult['force'].toString()});
      deInjector.get<Map<String, String>>().addAll(_parseExtraArgs(parserResult['extra-arg']));
      switch (parserResult.command?.name) {
        case 'env':
          final buildType = BuildType.fromString(
            BuildType.release.name,
          );
          deInjector.get<Map<String, String>>().addAll({'BUILD_MODE': buildType.name});
          deInjector.get<Map<String, String>>().addAll(buildType.environmentParams);
          deInjector.get<Map<String, String>>().addAll({'PLATFORM': 'android'});

          return VariableCheckConfig(
            isForced: parserResult['force'],
            generate: parserResult.command?['generate'] ?? false,
          );
        case 'install':
          return HemInstallAppConfig(
            isForced: parserResult['force'],
          );
        case 'builder':
          final builderCommand = parserResult.command!;
          return PubBuildRunnerConfig(
            watch: builderCommand['watch'],
            deleteConflictingOutputs: builderCommand['clean'],
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
            outputType: buildCommand['output-type'],
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
    );
    exit(64);
  }

  static String stager = '  ';
  static String dissolveHelpCommand(Map<String, ArgParser> commands, [String spacer = '']) {
    if (commands.isEmpty) {
      return '';
    }

    return commands.entries
        .map(
          (e) => '$spacer${e.key}\n$stager$spacer${e.value.usage.replaceAll(
            '\n',
            '\n$stager$spacer',
          )}\n${dissolveHelpCommand(
            e.value.commands,
            stager,
          )}',
        )
        .join('\n');
  }

  static Map<String, String> _parseExtraArgs(List<String>? envs) {
    if (envs == null) {
      return {};
    }
    final extraArgs = <String, String>{};
    for (final env in envs) {
      final split = env.split('=');
      if (split.length == 2) {
        extraArgs[split[0].toUpperCase()] = split[1];
      } else {
        showHelp('invalid environment variable: $env the format is: key=value');
      }
    }
    return extraArgs;
  }

  // static Map<String, dynamic> _dissolveEnvType(Map<String, String> env) {
  //   Map<String, dynamic> result = {};
  //   for (final e in env.entries) {
  //     if (int.tryParse(e.value) is int) {
  //       result[e.key] = int.parse(e.value);
  //     } else if (e.value == 'true' || e.value == 'false') {
  //       result[e.key] = e.value == 'true';
  //     } else {
  //       result[e.key] = e.value;
  //     }
  //   }
  //   return result;
  // }
}
