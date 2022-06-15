import 'package:hemend_toolkit/features/build_tools/platforms/android/extensions/build_type_extension.dart';

import '../../../core/contracts/build_config/build_config.dart';
import '../../../core/contracts/enums/build_mode.dart';

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

  @override
  String get outputFileAddress => 'build/app/outputs/flutter-apk/';
}
