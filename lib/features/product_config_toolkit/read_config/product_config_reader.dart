// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:yaml/yaml.dart' show loadYaml, YamlMap;

import '../../../core/dependency_injector/basic_dependency_injector.dart';
import '../../../core/io/command_line_toolkit/command_line_tools.dart';
import '../../build_tools/core/contracts/typedefs/typedefs.dart';
import '../core/product_config_defaults.dart' show kProductConfigFileName, kPubspecFileName;
import 'project_config_reader.dart';

EnvironmentParams readConfigLinks() {
  if (!ProjectConfigs.hasHemendspec) {
    cli
      ..printToConsole(
        'Hemendspec file not found.',
        isError: true,
      )
      ..printToConsole('you can generate it with `hem init`.');
    exit(64);
  }

  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;

    final envs = dissolveNestedItems(
      config['ENV_CONFIG'],
      'ENV_CONFIG',
    );
    final params = _castToEnvParams(
      _applyRules(
        _castToEnvParams(
          envs,
          deInjector.get<Map<String, String>>(),
        ),
        deInjector.get<Map<String, String>>(),
      ),
      deInjector.get<Map<String, String>>(),
    );
    deInjector.get<Map<String, String>>().addAll(params);
    cli.verbosePrint('Environments config: $params');

    return params;
  } catch (e) {
    cli
      ..printToConsole(
        'cannot read config file.',
        isError: true,
      )
      ..printToConsole(
        '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
ENV_CONFIG:
    *: *

Error Reason: $e
''',
        isError: true,
      );
    exit(64);
  }
}

EnvironmentParams readHemendCliConfig() {
  if (!ProjectConfigs.hasHemendspec) {
    cli
      ..printToConsole(
        'Hemendspec file not found.',
        isError: true,
      )
      ..printToConsole('you can generate it with `hem init`.');
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
    cli
      ..printToConsole(
        'cannot read config file.',
        isError: true,
      )
      ..printToConsole(
        '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
HEMEND_CONFIG:
  *: *

Error Reason: $e
''',
        isError: true,
      );
    exit(64);
  }
}

EnvironmentParams readPubspecInfo() {
  if (!ProjectConfigs.hasPubspec) {
    cli.printToConsole(
      'Pubspec file not found.',
      isError: true,
    );
    exit(64);
  }

  try {
    final config = loadYaml(File(kPubspecFileName).readAsStringSync()) as YamlMap;
    final params = _castToEnvParams(
      dissolveNestedItems(
        {
          'NAME': config['name'],
          'VERSION': config['version'],
        },
        'APP_CONFIG',
      ),
      readConfigLinks(),
    );
    deInjector.get<Map<String, String>>().addAll(params);
    cli.verbosePrint('app config: $params');
    return params;
  } catch (e) {
    cli
      ..printToConsole(
        'cannot read config file.',
        isError: true,
      )
      ..printToConsole(
        '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
ENV:
  *: *

Error Reason: $e
''',
        isError: true,
      );
    exit(64);
  }
}

EnvironmentParams readProductConfig() {
  if (!ProjectConfigs.hasHemendspec) {
    cli
      ..printToConsole(
        'Hemendspec file not found.',
        isError: true,
      )
      ..printToConsole('you can generate it with `hem init`.');
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
    cli
      ..printToConsole(
        'cannot read config file.',
        isError: true,
      )
      ..printToConsole(
        '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
ENV:
  *: *

Error Reason: $e
''',
        isError: true,
      );
    exit(64);
  }
}

EnvironmentParams _castToEnvParams(Map<dynamic, dynamic> from, EnvironmentParams links) {
  return Map<String, String>.fromEntries(
    from.entries.map((e) => MapEntry(e.key.toString(), _applyLink(e.value.toString(), links))),
  );
}

Map<String, String> normalizerSheetMap = {
  r'$empStr': '',
  r'$spaceStr': ' ',
  r'$comma': ',',
  r'$colon': ':',
};
String _normalizeArgs(final String arg) {
  var result = arg;
  for (final i in normalizerSheetMap.entries) {
    result = result.replaceAll(i.key, i.value);
  }
  return result;
}

EnvironmentParams _applyRules(EnvironmentParams base, Map<String, dynamic> rules) {
  cli.verbosePrint('internal environments config: $rules');

  final result = EnvironmentParams.from(base);
  for (final i in rules.entries.map((e) => MapEntry(e.key.toString(), e.value.toString()))) {
    for (final item in base.entries) {
      final args = item.value.split(' ');
      try {
        if (args[0].toUpperCase() == 'IF' && args[1] == i.key) {
          switch (args[2]) {
            case '==':
              if (args[3] == i.value) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            case '!=':
              if (args[3] != i.value) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            case '<=':
              final intValue = int.parse(args[3]);
              if (intValue >= int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            case '>=':
              final intValue = int.parse(args[3]);
              if (intValue <= int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            case '>':
              final intValue = int.parse(args[3]);
              if (intValue < int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            case '<':
              final intValue = int.parse(args[3]);
              if (intValue > int.parse(i.value)) {
                result[item.key] = _normalizeArgs(args[5].toString());
              } else {
                result[item.key] = _normalizeArgs(args[7].toString());
              }
              break;
            default:
              throw Exception('this Query has not implemented yet');
          }
        } else if (args[0].toUpperCase() == 'SWITCH' && args[1] == i.key) {
          final cases = Map.fromEntries(
            item.value
                .replaceAll(
                  args[0],
                  '',
                )
                .replaceAll(
                  args[1],
                  '',
                )
                .trim()
                .split(
                  ',',
                )
                .map(
                  (e) => MapEntry(
                    e.split(':')[0].toUpperCase().trim(),
                    e.split(':')[1],
                  ),
                ),
          );
          final valueByCase = cases[i.value.toUpperCase().trim()] ?? cases['DEFAULT'] ?? i.value;
          result[item.key] = _normalizeArgs(valueByCase);
        }
      } catch (e) {
        cli.printToConsole(
          'cannot apply a rule cause: $e',
          isError: true,
        );
      }
    }
  }
  cli.verbosePrint(
    '''
  base config: $base

  after applying rules: $result
''',
  );
  return result;
}

String _applyLink(String input, EnvironmentParams links) {
  var result = input;
  for (final key in links.keys) {
    result = result.replaceAll('\${$key}', links[key] ?? '');
  }
  return result;
}

Map<String, dynamic> dissolveNestedItems(
  Map<dynamic, dynamic> params, [
  String? prefix,
]) {
  var result = params;
  if (result is YamlMap) {
    result = Map.fromEntries(params.entries);
  }
  final newParams = <String, dynamic>{};
  for (final item in result.entries) {
    if (item.value is Map) {
      newParams.addAll(dissolveNestedItems(item.value, '${prefix}_${item.key}'));
    } else {
      final effectiveValue = item.value;
      if (effectiveValue is Iterable) {
        newParams['${prefix}_${item.key}'] = effectiveValue.join(',');
      } else {
        newParams['${prefix}_${item.key}'] = effectiveValue;
      }
    }
  }

  return newParams;
}
