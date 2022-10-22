import 'package:hemend/build_environments/build_environments.dart';
import '../../../core/contracts/build_config/build_config.dart';

class LinuxBuildConfig extends ObfuscatedBuildConfig {
  @override
  List<String> get buildCommand => [
        ...super.buildCommand,
        'linux',
      ];

  @override
  Future<List<String>> get builderParams async => [
        ...await super.builderParams,
      ];

  LinuxBuildConfig({
    super.buildType = BuildType.release,
  });

  @override
  String get outputFileAddress => 'build/linux/x64/release';
}
