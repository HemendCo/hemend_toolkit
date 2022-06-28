import '../../../core/contracts/build_config/build_config.dart';
import '../../../core/contracts/enums/build_mode.dart';

class IosBuildConfig extends ObfuscatedBuildConfig {
  @override
  List<String> get buildCommand => [
        ...super.buildCommand,
        'ipa',
      ];

  @override
  Future<List<String>> get builderParams async => [
        ...await super.builderParams,
      ];

  IosBuildConfig({
    super.buildType = BuildType.release,
  });

  @override
  String get outputFileAddress => 'build/ios/archive/';
}
