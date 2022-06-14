import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:hemend_toolkit/features/build_method/platforms/android/build_configs/normal_build_config.dart';

import 'package:hemend_toolkit/hemend_toolkit.dart' as hemend_toolkit;

void main(List<String> arguments) {
  CLI();
  AndroidNormalBuildConfig().builderParams.then((value) => CLI.I.printToConsole(value));
  hemend_toolkit.appEntry(arguments);
}
