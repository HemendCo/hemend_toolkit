import '../../../features/build_tools/core/contracts/build_config/build_config.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../../../features/build_tools/platforms/android/build_configs/android_build_config.dart';

abstract class HemendAppConfig {}

class PubAppConfig extends HemendAppConfig {}

class BuildAppConfig extends HemendAppConfig {
  final BuildPlatform platform;
  final BuildType buildType;

  BuildAppConfig(this.platform, this.buildType);
  IBuildConfig get getBuildConfig {
    switch (platform) {
      case BuildPlatform.android:
        return AndroidBuildConfig(buildType: buildType);
      case BuildPlatform.ios:
        throw UnimplementedError();
    }
  }
}

class CrashlytixAppConfig extends HemendAppConfig {}
