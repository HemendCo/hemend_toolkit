import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/read_config/project_config_reader.dart';
import 'package:yaml/yaml.dart' show loadYaml, YamlMap;

import '../../build_tools/core/contracts/typedefs/typedefs.dart';
import '../core/product_config_defaults.dart' show kProductConfigFileName;

EnvironmentParams readHemendCliConfig() {
  if (!ProjectConfigs.hasHemendspec) {
    HemTerminal.I.printToConsole(
      'Hemendspec file not found.',
      isError: true,
    );

    HemTerminal.I.printToConsole('you can generate it with `hem init`.');
    exit(64);
  }
  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
    final params = _castToEnvParams(
      dissolveNestedItems(
        config['HEMEND_CONFIG'],
        'HEMEND_CONFIG',
      ),
    );
    DeInjector.get<Map<String, String>>().addAll(params);
    return params;
  } catch (e) {
    HemTerminal.I.printToConsole(
      'cannot read config file.',
      isError: true,
    );
    HemTerminal.I.printToConsole(
      '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
env:
  CONFIG:
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
    HemTerminal.I.printToConsole(
      'Hemendspec file not found.',
      isError: true,
    );
    HemTerminal.I.printToConsole('you can generate it with `hem init`.');
    exit(64);
  }
  try {
    final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
    final params = _castToEnvParams(
      dissolveNestedItems(
        config['ENV'],
        'CONFIG',
      ),
    );
    DeInjector.get<Map<String, String>>().addAll(params);
    return params;
  } catch (e) {
    HemTerminal.I.printToConsole(
      'cannot read config file.',
      isError: true,
    );
    HemTerminal.I.printToConsole(
      '''regenerate it with `hem init --force`.
otherwise you can fix this issue by editing the file manually.
the issue is in 'hemendspec.yaml'
env:
  CONFIG:
    *: *
without any `-` before the key

the exception is $e
''',
      isError: true,
    );
    exit(64);
  }
}

EnvironmentParams _castToEnvParams(Map<dynamic, dynamic> from) {
  return Map<String, String>.fromEntries(from.entries.map((e) => MapEntry(e.key.toString(), e.value.toString())));
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
