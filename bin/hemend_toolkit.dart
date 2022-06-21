import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config_parser/app_config_parser.dart';
import 'package:hemend_toolkit/hemend_toolkit.dart';

void main(List<String> arguments) async {
  deInjector.register(DateTime.now());

  deInjector.register(<String, String>{});
  deInjector.get<Map<String, String>>().addAll(_splitDateTime(deInjector.get()));
  final config = await AppConfigParser.parsAndRun(arguments);
  await appEntry(config);
}

Map<String, String> _splitDateTime(DateTime dt) {
  return {
    'DATE_TIME_ISO': dt.toIso8601String(),
    'DATE_TIME_YEAR': dt.year.toString(),
    'DATE_TIME_MONTH': dt.month.toString(),
    'DATE_TIME_DAY': dt.day.toString(),
    'DATE_TIME_HOUR': dt.hour.toString(),
    'DATE_TIME_MINUTE': dt.minute.toString(),
    'DATE_TIME_SECOND': dt.second.toString(),
  };
}
