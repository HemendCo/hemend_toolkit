import 'dart:io';

import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config_parser/app_config_parser.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/git_toolkit/git_toolkit.dart';
import 'package:hemend_toolkit/hemend_toolkit.dart';

Future<Never> disrupt() async {
  // print(strYaml);
  await GitToolkit.hasUncommittedChanges();
  exit(0);
}

void main(List<String> arguments) async {
  // await disrupt();
  deInjector.register(<String, String>{});
  // readHemendCliConfig();
  try {
    deInjector
      ..register(DateTime.now())
      ..register(
        <String, String>{
          // ignore: lines_longer_than_80_chars
          'BUILD_DATE_TIME': //
              (deInjector.get<DateTime>().millisecondsSinceEpoch ~/ 1000) //
                  .toString(),
        },
      );
    deInjector.get<Map<String, String>>().addAll(
          _splitDateTime(deInjector.get()),
        );
    final config = await AppConfigParser.parsAndRun(arguments);
    await appEntry(config);
  } catch (e) {
    cli.printToConsole(
      '\nError: $e',
      isError: true,
    );
    // AppConfigParser.showHelp();
  }
}

Map<String, String> _splitDateTime(DateTime dt) {
  return {
    'BUILD_DATE_TIME_ISO': dt.toIso8601String(),
    'BUILD_DATE_TIME_YEAR': dt.year.toString(),
    'BUILD_DATE_TIME_MONTH': dt.month.toString(),
    'BUILD_DATE_TIME_DAY': dt.day.toString(),
    'BUILD_DATE_TIME_HOUR': dt.hour.toString(),
    'BUILD_DATE_TIME_MINUTE': dt.minute.toString(),
    'BUILD_DATE_TIME_SECOND': dt.second.toString(),
  };
}
