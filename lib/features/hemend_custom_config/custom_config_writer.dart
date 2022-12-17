import 'dart:convert';
import 'dart:io';

import '../../core/io/command_line_toolkit/command_line_tools.dart';
import 'custom_config_reader.dart';

const hemendConfigFilePath = 'hemend_configs.json';
const _basicConfig = [
  {
    'name': 'build',
    'description': 'Sample Build Config',
    'type': 'build',
    'build_arg': 'apk',
    'output_type': 'apk',
    'build_type': 'release',
    'is_online': false,
    'is_verbos': true,
    'is_forced': false,
    'extra_args': [
      'BUILD_FOR=GOOGLE',
    ],
  }
];
Future<void> generateBasicCustomConfig(bool isForced) async {
  if (!hasCustomConfigFile || isForced) {
    final json = jsonEncode(_basicConfig);
    await File(hemendConfigFilePath).writeAsString(json);
  } else {
    cli.printToConsole('custom config file already exists.');
  }
}
