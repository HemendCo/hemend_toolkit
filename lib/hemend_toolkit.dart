import 'core/hemend_toolkit_config/app_config/app_config.dart';
import 'core/io/command_line_toolkit/command_line_tools.dart';

Future<void> appEntry(IAppConfig config) async {
  cli.printToConsole('received config for ${config.configName} module');
  await config.validateAndInvoke();
}
