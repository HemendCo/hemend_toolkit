import 'dart:io';

import 'package:meta/meta.dart';

import '../../core/io/command_line_toolkit/command_line_tools.dart';

abstract class IHemendCustomConfigModel {
  final String name;
  final String description;
  final String type;
  final bool isOnline;
  final bool isForced;
  final bool isVerbos;
  final List<String> extraArgs;
  static String get helpGenerator {
    final buffer = StringBuffer()
      ..writeln(
        '''`field name`<value type>(* means this field is required): description
        ''',
      )
      ..writeln(
        'these fields are present in all of config types:',
      )
      ..writeln(
        '`name`<String>* : name of config',
      )
      ..writeln(
        '`description`<String>* : description of config',
      )
      ..writeln(
        '`type`<String>* : type of config',
      )
      ..writeln(
        '`is_online`<bool> : sets cli to use online methods',
      )
      ..writeln(
        '`is_verbos`<bool> : sets cli mode to verbose',
      )
      ..writeln(
        '`is_forced`<bool> : sets cli mode to forced',
      )
      ..writeln(
        '''`extra_args`<List<String>> : adds parameters to config (e.g. ["test=true"])''',
      )
      ..writeln(
        '------------------------',
      )
      ..writeln('for configs of type `build`')
      ..writeln(
        '`build_arg`<String> : build for what platform (default value is apk)',
      )
      ..writeln(
        '`output_type`<String> : outputs file extension (default value is apk)',
      )
      ..writeln(
        '`build_type`<String> : output mode (default value is release)',
      )
      ..writeln(
        '------------------------',
      )
      ..writeln('for configs of type `pub`')
      ..writeln(
        '''`clean`<bool> : will clean before getting packages (default value is false)''',
      )
      ..writeln(
        '''`upgrade`<bool> : upgrade packages when its possible (default value is false)''',
      );

    return buffer.toString();
  }

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
          extraArgs: List<String>.from(input['extra_args'] ?? []),
        );
      case 'pub':
        return HemendCustomPubConfig(
          shouldClean: input['clean'] == true,
          shouldUpgrade: input['upgrade'] == true,
          name: input['name'].toString(),
          description: input['description'].toString(),
          type: input['type'].toString(),
          isOnline: input['is_online'] ?? false,
          isForced: input['is_forced'] ?? false,
          isVerbos: input['is_verbos'] ?? false,
          extraArgs: List<String>.from(input['extra_args'] ?? []),
        );
      default:
        cli.printToConsole(helpGenerator);
        exit(64);
    }
  }
  @mustCallSuper
  List<String> get asArgs => [
        if (isOnline) '-o',
        if (isForced) '-f',
        if (isVerbos) '-v',
        if (extraArgs.isNotEmpty) '-e',
        if (extraArgs.isNotEmpty) extraArgs.join(',')
      ];
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
      ...super.asArgs,
    ];
  }
}

class HemendCustomPubConfig extends IHemendCustomConfigModel {
  final bool shouldUpgrade;
  final bool shouldClean;
  HemendCustomPubConfig({
    required this.shouldUpgrade,
    required this.shouldClean,
    required super.name,
    required super.description,
    required super.type,
    required super.isOnline,
    required super.isForced,
    required super.isVerbos,
    required super.extraArgs,
  });

  @override
  List<String> get asArgs => [
        'get',
        if (shouldClean) '-c',
        if (shouldUpgrade) '-u',
        ...super.asArgs,
      ];
}
