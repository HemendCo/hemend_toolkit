enum BuildPlatform {
  android,
  windows,
  linux,
  web,
  mac,
  ios;

  factory BuildPlatform.fromString(String? value) {
    switch (value) {
      case 'apk':
        return android;
      case 'ios':
        return ios;
      case 'web':
        return web;
      case 'windows':
        return windows;
      case 'linux':
        return linux;
      default:
        throw ArgumentError('Unknown build platform: $value');
    }
  }
}
