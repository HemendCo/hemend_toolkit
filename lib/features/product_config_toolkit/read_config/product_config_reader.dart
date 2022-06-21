import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/read_config/project_config_reader.dart';
import 'package:yaml/yaml.dart' show loadYaml, YamlMap;

import '../../build_tools/core/contracts/typedefs/typedefs.dart';
import '../core/product_config_defaults.dart' show kProductConfigFileName;

EnvironmentParams readConfigLinks() {
  if (!ProjectConfigs.hasHemendspec) {
    cli.printToConsole(
      'Hemendspec file not found.',
      isError: true,
    );

    cli.printToConsole('you can generate it with `hem init`.');
    exit(64);
  }

  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
    final params = _applyRules(
      _castToEnvParams(
        dissolveNestedItems(
          config['ENV_CONFIG'],
          'ENV_CONFIG',
        ),
        {},
      ),
      deInjector.get<Map<String, String>>(),
    )..addAll(deInjector.get<Map<String, String>>());
    deInjector.get<Map<String, String>>().addAll(params);
    cli.verbosePrint('Environments config: $params');
    return params;
  } catch (e) {
    cli.printToConsole(
      'cannot read config file.',
      isError: true,
    );
    cli.printToConsole(
      '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
ENV_CONFIG:
    *: *
without any `-` before the key

the exception is $e
''',
      isError: true,
    );
    exit(64);
  }
}

EnvironmentParams readHemendCliConfig() {
  if (!ProjectConfigs.hasHemendspec) {
    cli.printToConsole(
      'Hemendspec file not found.',
      isError: true,
    );

    cli.printToConsole('you can generate it with `hem init`.');
    exit(64);
  }
  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
    final params = _castToEnvParams(
      dissolveNestedItems(
        config['HEMEND_CONFIG'],
        'HEMEND_CONFIG',
      ),
      readConfigLinks(),
    );
    deInjector.get<Map<String, String>>().addAll(params);
    cli.verbosePrint('Hem config: $params');
    return params;
  } catch (e) {
    cli.printToConsole(
      'cannot read config file.',
      isError: true,
    );
    cli.printToConsole(
      '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
HEMEND_CONFIG:
  *: *
without any `-` before the key

the exception is $e
''',
      isError: true,
    );
    exit(64);
  }
}

EnvironmentParams readProductConfig() {
  if (!ProjectConfigs.hasHemendspec) {
    cli.printToConsole(
      'Hemendspec file not found.',
      isError: true,
    );
    cli.printToConsole('you can generate it with `hem init`.');
    exit(64);
  }

  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
    final params = _castToEnvParams(
      dissolveNestedItems(
        config['ENV'],
        'CONFIG',
      ),
      readConfigLinks(),
    );
    deInjector.get<Map<String, String>>().addAll(params);
    cli.verbosePrint('app config: $params');
    return params;
  } catch (e) {
    cli.printToConsole(
      'cannot read config file.',
      isError: true,
    );
    cli.printToConsole(
      '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
ENV:
  *: *
without any `-` before the key

the exception is $e
''',
      isError: true,
    );
    exit(64);
  }
}

EnvironmentParams _castToEnvParams(Map<dynamic, dynamic> from, EnvironmentParams links) {
  return Map<String, String>.fromEntries(
      from.entries.map((e) => MapEntry(e.key.toString(), _applyLink(e.value.toString(), links))));
}

Map<String, String> normalizerSheetMap = {
  r'$empStr': '',
  r'$spaceStr': ' ',
};
String _normalizeArgs(String arg) {
  return normalizerSheetMap[arg] ?? arg;
}

EnvironmentParams _applyRules(EnvironmentParams base, EnvironmentParams rules) {
  cli.verbosePrint('internal environments config: $rules');

  final result = EnvironmentParams.from(base);
  for (final i in rules.entries) {
    for (final item in base.entries) {
      final args = item.value.split(' ');
      try {
        if (args[0] == 'WHERE' && args[1] == i.key) {
          switch (args[2]) {
            case '=':
              if (args[3] == i.value) {
                result[item.key] = _normalizeArgs(args[5]);
              } else {
                result[item.key] = _normalizeArgs(args[7]);
              }
              break;
            case '<=':
              final intValue = int.parse(args[3]);
              if (intValue >= int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5]);
              } else {
                result[item.key] = _normalizeArgs(args[7]);
              }
              break;
            case '>=':
              final intValue = int.parse(args[3]);
              if (intValue <= int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5]);
              } else {
                result[item.key] = _normalizeArgs(args[7]);
              }
              break;
            case '>':
              final intValue = int.parse(args[3]);
              if (intValue < int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5]);
              } else {
                result[item.key] = _normalizeArgs(args[7]);
              }
              break;
            case '<':
              final intValue = int.parse(args[3]);
              if (intValue > int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5]);
              } else {
                result[item.key] = _normalizeArgs(args[7]);
              }
              break;
            default:
              throw Exception('this Query has not implemented yet');
          }
        }
      } catch (e) {
        cli.printToConsole(
          'cannot apply a rule cause: $e',
          isError: true,
        );
      }
    }
  }
  cli.verbosePrint('''
  base config: $base

  after applying rules: $result
''');
  return result;
}

String _applyLink(String input, EnvironmentParams links) {
  String result = input;
  for (final key in links.keys) {
    result = result.replaceAll('\${$key}', links[key] ?? '');
  }
  return result;
}

Map<String, dynamic> dissolveNestedItems(Map<dynamic, dynamic> params, [String? prefix]) {
  if (params is YamlMap) {
    params = Map.fromEntries(params.entries);
  }
  final newParams = <String, dynamic>{};
  for (final item in params.entries) {
    if (item.value is Map) {
      newParams.addAll(dissolveNestedItems(item.value, '${prefix}_${item.key}'));
    } else {
      newParams['${prefix}_${item.key}'] = item.value;
    }
  }

  return newParams;
}
