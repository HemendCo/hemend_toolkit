import 'dart:io';

import 'package:hemend_toolkit/features/product_config_toolkit/core/product_config_defaults.dart';

abstract class ProjectConfigs {
  static bool get hasHemendspec => File(kProductConfigFileName).existsSync();
  static bool get hasPubspec => File(kPubspecFileName).existsSync();
  static bool get hasAndroid => Directory('android').existsSync();
  static bool get hasIos => Directory('ios').existsSync();
  static bool get hasLinux => Directory('linux').existsSync();
  static bool get hasWindows => Directory('windows').existsSync();
}
