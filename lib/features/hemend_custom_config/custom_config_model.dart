import 'package:meta/meta.dart';

abstract class IHemendCustomConfigModel {
  final String name;
  final String description;
  final String type;
  final bool isOnline;
  final bool isForced;
  final bool isVerbos;
  final List<String> extraArgs;

  IHemendCustomConfigModel({
    required this.name,
    required this.description,
    required this.type,
    required this.isOnline,
    required this.isForced,
    required this.isVerbos,
    required this.extraArgs,
  });
  factory IHemendCustomConfigModel.fromJson(Map<String, dynamic> input) {
    switch (input['type']) {
      case 'build':
        return HemendCustomBuildConfig(
          buildArg: input['build_arg'] ?? 'apk',
          outputType: input['output_type'] ?? 'apk',
          buildType: input['build_type'] ?? 'release',
          name: input['name'].toString(),
          description: input['description'].toString(),
          type: input['type'].toString(),
          isOnline: input['is_online'] ?? false,
          isForced: input['is_forced'] ?? false,
          isVerbos: input['is_verbos'] ?? false,
          extraArgs: List<String>.from(input['extra-args'] ?? []),
        );
      default:
        throw 'Unknown Type Error';
    }
  }
  List<String> get asArgs;
}

class HemendCustomBuildConfig extends IHemendCustomConfigModel {
  final String buildArg;
  final String outputType;
  final String buildType;
  HemendCustomBuildConfig({
    required this.buildArg,
    required this.outputType,
    required this.buildType,
    required super.name,
    required super.description,
    required super.type,
    required super.isOnline,
    required super.isForced,
    required super.isVerbos,
    required super.extraArgs,
  });

  @override
  List<String> get asArgs {
    return [
      'build',
      buildArg,
      '-t',
      outputType,
      '-m',
      buildType,
      if (isOnline) '-o',
      if (isForced) '-f',
      if (isVerbos) '-v',
      if (extraArgs.isNotEmpty) '-e',
      if (extraArgs.isNotEmpty) extraArgs.join(',')
    ];
  }
}
