import 'dart:convert';
import 'dart:io';

import '../../core/hemend_toolkit_config/app_config/app_config.dart';
import '../../core/hemend_toolkit_config/app_config_parser/app_config_parser.dart';
import '../../core/io/command_line_toolkit/command_line_tools.dart';
import 'custom_config_model.dart';
import 'custom_config_writer.dart';

final hasCustomConfigFile = File(hemendConfigFilePath).existsSync();
Future<IAppConfig> readCustomConfig() {
  if (!hasCustomConfigFile) {
    cli
      ..printToConsole(
        'custom config file not found.',
        isError: true,
      )
      ..printToConsole('you can generate it with `hem init`.')
      ..printToConsole('to see other command use `hem help`.');
  }
  final configJson = File(hemendConfigFilePath).readAsStringSync();
  final config = List<Map<String, dynamic>>.from(jsonDecode(configJson));
  final configs = config.map(IHemendCustomConfigModel.fromJson).toList();
  cli.printToConsole(
    '''Found ${configs.length} custom configs.
name\t(type):\tdescription
''',
  );

  for (final i in configs) {
    cli.printToConsole(
      '${i.name}\t(${i.type}):\t${i.description}',
    );
  }
  cli.printToConsole('Enter name of custom config to use:');
  final selectedConfig = cli.readLineFromConsole();
  final selectedConfigs = configs.where((i) => i.name == selectedConfig);
  if (selectedConfigs.isEmpty) {
    cli.printToConsole('no config found with name $selectedConfig');
    exit(64);
  }
  return AppConfigParser.parsAndRun(selectedConfigs.first.asArgs);
}
