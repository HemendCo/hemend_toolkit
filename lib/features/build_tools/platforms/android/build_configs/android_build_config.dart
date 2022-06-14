import 'package:hemend_toolkit/features/build_tools/contracts/enums/build_mode.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/android/extensions/build_type_extension.dart';

import '../../../contracts/build_config/build_config.dart';

class AndroidBuildConfig extends ObfuscatedBuildConfig {
  @override
  List<String> get buildCommand => [
        ...super.buildCommand,
        'apk',
      ];

  Iterable<String> get platformNames => buildType.androidPlatforms.map((e) => e.platformName);
  Iterable<String> get _platformParams => [
        '--target-platform',
        platformNames.join(','),
      ];

  @override
  Future<List<String>> get builderParams async => [
        ...(await super.builderParams),
        ..._platformParams,
      ];

  @override
  final BuildType buildType;
  AndroidBuildConfig({
    this.buildType = BuildType.release,
  });
}
