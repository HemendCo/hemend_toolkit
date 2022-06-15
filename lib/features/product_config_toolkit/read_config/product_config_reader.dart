import 'dart:io';

import 'package:yaml/yaml.dart' show loadYaml, YamlMap;

import '../../build_tools/core/contracts/typedefs/typedefs.dart';
import '../core/product_config_defaults.dart' show kProductConfigFileName;

EnvironmentParams readProductConfig() {
  final config = loadYaml(File(kProductConfigFileName).readAsStringSync()) as YamlMap;
  final params = _castToEnvParams(
    dissolveNestedItems(
      config['env'],
      'CONFIG',
    ),
  );

  return params;
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
