import '../../../core/contracts/enums/build_mode.dart';
import '../enums/android_platforms.dart';

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
          // ignore: deprecated_member_use_from_same_package
          AndroidPlatforms.X86,
        ]);
        break;
      default:
        break;
    }
    return result;
  }
}
