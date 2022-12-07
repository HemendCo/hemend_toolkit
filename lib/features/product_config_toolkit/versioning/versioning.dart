import 'dart:io';

import 'package:yaml_modify/yaml_modify.dart';

class VersioningSystem {
  int major = 0;
  int minor = 0;
  int patch = 0;
  int buildNumber = 0;

  VersioningSystem(String source) {
    final versionAndBuildNum = source.split('+');
    if (versionAndBuildNum.isEmpty) {
      return;
    } else if (versionAndBuildNum.length == 1) {
      buildNumber = 0;
    } else if (versionAndBuildNum.length > 2) {
      throw Exception(
        'cannot understand this versioning system `$source`, expected: 1.1.5+6',
      );
    } else if (versionAndBuildNum.length == 2) {
      buildNumber = int.parse(versionAndBuildNum[1]);
    }
    final version = versionAndBuildNum.first.split('.');
    if (version.length != 3) {
      throw Exception(
        'cannot understand this versioning system `$source`, expected: 1.1.5+6',
      );
    }
    major = int.tryParse(version[0]) ?? 0;
    minor = int.tryParse(version[1]) ?? 0;
    patch = int.tryParse(version[2]) ?? 0;
  }
  @override
  String toString() {
    return '$major.$minor.$patch+$buildNumber';
  }
}

void increaseBuildNumber() {
  final pubspecFile = File('pubspec.yaml');
  final allContents = pubspecFile.readAsStringSync();
  final data = loadYaml(
    allContents,
  );

  final modifiable = getModifiableNode(data);
  final source_version = VersioningSystem(modifiable['version']);
  source_version.buildNumber++;
  modifiable['version'] = source_version.toString();

  final strYaml = toYamlString(modifiable);
  pubspecFile
    ..copySync('pubspec.yaml-b')
    ..writeAsStringSync(strYaml);
}
