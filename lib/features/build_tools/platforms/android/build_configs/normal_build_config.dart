import '../../../contracts/build_config/build_config.dart';
import '../enums/android_platforms.dart';

class AndroidNormalBuildConfig extends ObfuscatedBuildConfig {
  @override
  List<String> get buildCommand => [
        ...super.buildCommand,
        'apk',
      ];

  Set<AndroidPlatforms> get _androidPlatforms => {
        AndroidPlatforms.ARM,
        AndroidPlatforms.ARM64,

        ///Conditional
        AndroidPlatforms.X64,
      };
  Iterable<String> get platformNames => _androidPlatforms.map((e) => e.platformName);
  Iterable<String> get _platformParams => [
        '--target-platform',
        platformNames.join(','),
      ];

  @override
  Future<List<String>> get builderParams async => [
        ...(await super.builderParams),
        ..._platformParams,
      ];
}
