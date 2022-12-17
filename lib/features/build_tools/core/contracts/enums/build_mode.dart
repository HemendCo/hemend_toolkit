// ignore_for_file: do_not_use_environment, constant_identifier_names, lines_longer_than_80_chars

enum BuildType {
  release(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'RELEASE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '0',
    },
  ),
  debug(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'DEBUG',
      'HEMEND_CONFIG_DEBUG_LEVEL': '2',
    },
  ),
  profile(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PROFILE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
    },
  ),
  debugBuild(
    buildParams: [
      '--debug',
    ],
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'DEBUG',
      'HEMEND_CONFIG_DEBUG_LEVEL': '2',
    },
  ),
  performance(
    buildParams: [
      '--profile',
    ],
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PERFORMANCE',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
    },
  ),
  presentation(
    environmentParams: {
      'HEMEND_CONFIG_RELEASE_MODE': 'PRESENTATION',
      'HEMEND_CONFIG_DEBUG_LEVEL': '1',
    },
  );

  const BuildType({
    this.buildParams = const [],
    required this.environmentParams,
  });
  factory BuildType.byIndex(int index) => values[index];
  factory BuildType.fromString(
    String name,
  ) =>
      values.firstWhere(
        (element) => element.name == name.toLowerCase(),
      );
  Map<String, dynamic> toMap() => {
        'type': name,
        'buildParams': buildParams,
        'environmentParams': environmentParams,
      };

  final List<String> buildParams;
  final Map<String, String> environmentParams;
}
