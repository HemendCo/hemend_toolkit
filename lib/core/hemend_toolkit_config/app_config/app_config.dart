import 'package:hemend_toolkit/features/build_tools/contracts/enums/build_mode.dart';

import '../../../features/build_tools/contracts/build_config/build_config.dart';
import '../../../features/build_tools/platforms/android/build_configs/android_build_config.dart';
import '../../../features/build_tools/platforms/core/enums/platforms.dart';

abstract class HemendAppConfig {}

class PubAppConfig {}

class BuildAppConfig {
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

class CrashlytixAppConfig {}
