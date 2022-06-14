enum BuildPlatform {
  android,
  ios;

  factory BuildPlatform.fromString(String? value) {
    switch (value) {
      case 'apk':
        return android;
      case 'ios':
        return ios;
      default:
        throw Exception('Unknown platform: $value');
    }
  }
}
