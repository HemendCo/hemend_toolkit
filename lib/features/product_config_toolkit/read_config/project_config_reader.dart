import 'dart:io';

import 'package:hemend_toolkit/features/product_config_toolkit/core/product_config_defaults.dart';

import '../../build_tools/core/enums/platforms.dart';

abstract class ProjectConfigs {
  static bool get hasHemendspec => File(kProductConfigFileName).existsSync();
  static bool get hasPubspec => File(kPubspecFileName).existsSync();
  static bool get hasAndroid => Directory('android').existsSync();
  static bool get hasIos => Directory('ios').existsSync();
  static bool get hasLinux => Directory('linux').existsSync();
  static bool get hasWindows => Directory('windows').existsSync();
  static bool get hasWeb => Directory('web').existsSync();
  static bool get hasMac => Directory('macos').existsSync();
  static bool canBuildFor(BuildPlatform platform) {
    switch (platform) {
      case BuildPlatform.android:
        return hasAndroid;
      case BuildPlatform.ios:
        return hasIos;
      case BuildPlatform.linux:
        return hasLinux;
      case BuildPlatform.windows:
        return hasWindows;
      case BuildPlatform.web:
        return hasWindows;
      case BuildPlatform.mac:
        return hasMac;
    }
  }
}
