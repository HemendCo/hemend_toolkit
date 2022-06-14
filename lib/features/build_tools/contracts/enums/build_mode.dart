import '../typedefs/typedefs.dart';

enum BuildType {
  release(
    environmentParams: {
      'RELEASE_MODE': 'RELEASE',
      'DEBUG_LEVEL': '0',
    },
  ),
  debug(
    environmentParams: {
      'RELEASE_MODE': 'DEBUG',
      'DEBUG_LEVEL': '1',
    },
  ),
  profile(
    environmentParams: {
      'RELEASE_MODE': 'PROFILE',
      'DEBUG_LEVEL': '0',
    },
  ),
  debugBuild(
    buildParams: [
      '--debug',
    ],
    environmentParams: {
      'RELEASE_MODE': 'DEBUG',
      'DEBUG_LEVEL': '1',
    },
  ),
  presentation(
    environmentParams: {
      'RELEASE_MODE': 'PRESENTATION',
      'DEBUG_LEVEL': '0',
    },
  );

  const BuildType({
    this.buildParams = const [],
    required this.environmentParams,
  });
  factory BuildType.byIndex(int index) => values[index];
  factory BuildType.fromString(String name) => values.firstWhere(
        (element) => element.name == name,
      );

  final List<String> buildParams;
  final EnvironmentParams environmentParams;
}
