import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config/app_config.dart';
import 'package:hemend_toolkit/features/build_tools/core/contracts/build_config/build_config.dart';
import 'package:hemend_toolkit/features/build_tools/core/contracts/enums/build_mode.dart';
import 'package:hemend_toolkit/features/build_tools/core/enums/platforms.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/android/build_configs/android_build_config.dart';
import 'package:hemend_toolkit/features/build_tools/platforms/ios/build_configs/ios_build_config.dart';
import 'package:test/test.dart';

class MockedBuildAppConfig extends BuildAppConfig {
  MockedBuildAppConfig({required super.platform, required super.buildType, required super.isForced});
  @override
  String get getAppNameFormat => 'test';
}

void main() {
  group('testing app config methods', () {
    group('build app config', () {
      test('android', () {
        final config = MockedBuildAppConfig(
          platform: BuildPlatform.android,
          buildType: BuildType.release,
          isForced: false,
        );
        expect(config.getBuildConfig, TypeMatcher<AndroidBuildConfig>());
      });
      test('ios', () {
        final config = MockedBuildAppConfig(
          platform: BuildPlatform.ios,
          buildType: BuildType.release,
          isForced: false,
        );
        expect(config.getBuildConfig, TypeMatcher<IosBuildConfig>());
      });
      for (final i in [
        BuildPlatform.windows,
        BuildPlatform.web,
        BuildPlatform.linux,
        BuildPlatform.mac,
      ]) {
        test('others (${i.name})', () {
          final config = MockedBuildAppConfig(
            platform: i,
            buildType: BuildType.release,
            isForced: false,
          );
          expect(config.getBuildConfig, TypeMatcher<ObfuscatedBuildConfig>());
        });
      }
    });
  });
}
