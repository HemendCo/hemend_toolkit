import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config_parser/app_config_parser.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/android/build_configs/android_build_config.dart';
import 'package:hemend_toolkit/hemend_toolkit.dart';

void main(List<String> arguments) async {
  DeInjector.register(AndroidBuildConfig());
  DeInjector.register(DateTime.now());
  final config = await AppConfigParser.parsAndRun(arguments);
  await appEntry(config);
}
