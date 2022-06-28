import '../../../core/contracts/build_config/build_config.dart';
import '../../../core/contracts/enums/build_mode.dart';
import '../extensions/build_type_extension.dart';

class AndroidBuildConfig extends ObfuscatedBuildConfig {
  final String outputFormat;
  @override
  List<String> get buildCommand => [
        ...super.buildCommand,
        outputFormat,
      ];

  Iterable<String> get platformNames => buildType.androidPlatforms.map(
        (e) => e.platformName,
      );
  Iterable<String> get _platformParams => [
        '--target-platform',
        platformNames.join(','),
      ];

  @override
  Future<List<String>> get builderParams async => [
        ...await super.builderParams,
        ..._platformParams,
      ];

  AndroidBuildConfig({
    super.buildType = BuildType.release,
    required this.outputFormat,
    required this.nameFormat,
  });
  final String nameFormat;
  @override
  String get outputFileAddress => 'build/app/outputs/flutter-apk/app-release.apk';
}
