enum AndroidPlatforms {
  ARM('android-arm'),
  ARM64('android-arm64'),
  @Deprecated('Cannot be used in build')
  X86('android-x86'),
  X64('android-x64');

  const AndroidPlatforms(this.platformName);
  final String platformName;
}
