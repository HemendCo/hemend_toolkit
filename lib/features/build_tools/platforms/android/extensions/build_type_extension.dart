import 'package:hemend_toolkit/features/build_tools/platforms/android/enums/android_platforms.dart';

import '../../../contracts/enums/build_mode.dart';

extension BuildTypExtension on BuildType {
  Set<AndroidPlatforms> get androidPlatforms {
    final result = {
      AndroidPlatforms.ARM,
      AndroidPlatforms.ARM64,
    };

    switch (this) {
      case BuildType.presentation:
        result.add(AndroidPlatforms.X64);
        break;
      case BuildType.debugBuild:
        result.addAll([
          AndroidPlatforms.X64,
          AndroidPlatforms.X86,
        ]);
        break;
      default:
        break;
    }
    return result;
  }
}
