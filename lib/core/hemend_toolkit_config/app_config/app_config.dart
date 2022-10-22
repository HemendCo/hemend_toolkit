// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:meta/meta.dart';

import '../../../features/build_tools/core/build_toolkit.dart';
import '../../../features/build_tools/core/contracts/build_config/build_config.dart';
import '../../../features/build_tools/core/contracts/enums/build_mode.dart';
import '../../../features/build_tools/core/contracts/typedefs/typedefs.dart';
import '../../../features/build_tools/core/enums/platforms.dart';
import '../../../features/build_tools/platforms/android/build_configs/android_build_config.dart';
import '../../../features/build_tools/platforms/ios/build_configs/ios_build_config.dart';
import '../../../features/build_tools/platforms/linux/build_configs/linux_build_config.dart';
import '../../../features/build_tools/platforms/web/build_configs/web_build_config.dart';
import '../../../features/dart_build_runner/dart_build_runner.dart';
import '../../../features/git_toolkit/git_toolkit.dart';
import '../../../features/hemend_custom_config/custom_config_writer.dart';
import '../../../features/package_manager/pub.dart';
import '../../../features/product_config_toolkit/read_config/product_config_reader.dart';
import '../../../features/product_config_toolkit/read_config/project_config_reader.dart';
import '../../../features/product_config_toolkit/sample_creator/product_config_sample_creator.dart';
import '../../dependency_injector/basic_dependency_injector.dart';
import '../../io/command_line_toolkit/command_line_tools.dart';

Future<void> _populateEnvMap() async {
  await GitToolkit.getLastCommitsHash();
  await GitToolkit.getLastCommitsAuthorEmail();
  await GitToolkit.getLastCommitsEpochTime();
  readHemendCliConfig();
  readProductConfig();
  readPubspecInfo();
}

/// checks if `pubspec.yaml` file exists
void _checkPubspecYaml() {
  cli.verbosePrint('checking pubspec.yaml existence');
  if (!ProjectConfigs.hasPubspec) {
    cli
      ..printToConsole('Pubspec file not found.', isError: true)
      ..printToConsole('run this command in root of the project');
    exit(64);
  }
}

/// checks if `hemspec.yaml` file exists
void _checkHemspecYaml() {
  cli.verbosePrint('checking hemspec.yaml existence');
  if (!ProjectConfigs.hasHemendspec) {
    cli
      ..printToConsole('hemspec file not found.', isError: true)
      ..printToConsole(
        //
        'run `hem init` in root of the project to create `hemspec.yaml` file',
      );
    exit(64);
  }
}

/// config of the app in current session
/// it will hold needed parameters for current task
abstract class IAppConfig {
  /// name of the current config (e.g. `build`, `package manager`)
  String get configName;

  /// identify that current commands had a forced tag so the command will run
  /// in unsafe mode and override every safety method
  final bool isForced;

  IAppConfig({required this.isForced});

  /// executing this method before [_invoke] to validate the config to run the command
  ///
  ///**note:** if [isForced] was `true` config runner will ignore this method and directly run the command
  Future<void> _validate() async {}

  /// main part of the config command runner
  Future<void> _invoke();

  /// executing the validation and if it passed, run the command
  ///
  ///**note:** if [isForced] was `true` will override validation phase and run the command directly
  @mustCallSuper
  Future<void> validateAndInvoke() async {
    if (!isForced) {
      cli.verbosePrint('starting validation phase');
      await _validate();
      cli.verbosePrint('validation phase finished');
    } else {
      cli.verbosePrint(
        'running in unsafe mode (no validation before running commands)',
      );
    }
    cli.verbosePrint('executing the command');
    await _invoke();
  }

  @override
  String toString() => configName;
}

/// config for installing hem cli on OS and add it to system path
///
/// only **windows** is supported
class HemInstallAppConfig extends IAppConfig {
  HemInstallAppConfig({required super.isForced});

  @override
  Future<void> _invoke() async {
    cli.verbosePrint('installing hem cli');
    // get current process exe path

    // checking the platform currently limited to `windows`
    if (Directory(r'c:\windows').existsSync()) {
      final hemendAppFile = File(Platform.resolvedExecutable);
      cli.verbosePrint('windows platform detected');
      const hemendPath = r'C:\hemend';

      /// checking existence of older versions of CLI tool
      if (isForced || !File('$hemendPath\\hem.exe').existsSync()) {
        cli.verbosePrint('creating `$hemendPath` directory');
        Directory(hemendPath).createSync(recursive: true);
        cli.verbosePrint('copy file into directory');
        // ignore: avoid_slow_async_io
        await File('$hemendPath\\hem.exe').exists().then(
              (value) => //
                  value ? File('$hemendPath\\hem.exe').deleteSync() : null,
            );
        hemendAppFile.copySync(
          '$hemendPath\\hem.exe',
        );
        cli.verbosePrint('add $hemendPath to windows PATH');

        /// add `[hemendPath]` to system path
        await cli.runTaskInTerminal(
          name: 'Setting path',
          command: 'setx',
          runInShell: true,
          arguments: [
            '/m',
            'PATH',
            '$hemendPath;"%PATH%"',
          ],
        );
      } else {
        cli.printToConsole(
          '''hemend is already installed.
  to override this you need to run this command with --force(-f) option''',
          isError: true,
        );
      }
    } else {
      cli.printToConsole(
        '''installer is not supported on this `OS`
  you may need to set an alias or add this directory into \$Path manually''',
        isError: true,
      );
    }
  }

  @override
  String get configName => 'Hemend Install';
}

/// pub app config for running pub commands
/// it will run `pub get` and `pub upgrade` and `flutter clean` commands
class PubAppConfig extends IAppConfig {
  final bool shouldClean;
  final bool shouldUpgrade;
  PubAppConfig({
    required super.isForced,
    required this.shouldClean,
    required this.shouldUpgrade,
  });
  @override
  Future<void> _validate() async {
    _checkPubspecYaml();
  }

  @override
  Future<void> _invoke() async {
    if (isForced) {
      cli.printToConsole(
        'executed with --force (-f) flag, this command has no force mode and flag will be ignored',
        isError: true,
      );
    }
    // run pub clean if requested
    if (shouldClean) {
      await PackageManager.pubClean();
    }
    // run pub upgrade if requested
    if (shouldUpgrade) {
      await PackageManager.upgradePackages();
    }
    // finally run pub get
    await PackageManager.pubGet();
  }

  @override
  String get configName => 'Flutter Package Manager';
}

/// build app config for running build commands
class BuildAppConfig extends IAppConfig {
  /// build platform
  final BuildPlatform platform;

  /// build mode
  final BuildType buildType;
  final String outputType;
  BuildAppConfig({
    required this.platform,
    required this.buildType,
    required this.outputType,
    required super.isForced,
  });
  @override
  Future<void> _validate() async {
    // ─────────────────────────────────────────────────────────────────
    // validates if its is in a flutter project directory
    _checkPubspecYaml();
    _checkHemspecYaml();
    // ─────────────────────────────────────────────────────────────────

    cli.verbosePrint('checking possibility of building for ${platform.name}');
    // checks if can build for the requested platform
    if (!ProjectConfigs.canBuildFor(platform)) {
      cli
        ..printToConsole(
          'cannot find directory for platform: ${platform.name}',
          isError: true,
        )
        ..printToConsole('run this command in root of the project');
      exit(64);
    }
  }

  String get getAppNameFormat => //
      readHemendCliConfig()['HEMEND_CONFIG_NAME_FORMAT'] ?? 'error';

  /// get build config for selected platform
  ///
  /// currently supports **android** and **ios**
  IBuildConfig get getBuildConfig {
    cli.verbosePrint('building app for ${platform.name}');
    switch (platform) {
      case BuildPlatform.android:
        return AndroidBuildConfig(
          buildType: buildType,
          outputFormat: outputType,
          nameFormat: getAppNameFormat,
        );
      case BuildPlatform.ios:
        return IosBuildConfig(buildType: buildType);
      case BuildPlatform.linux:
        return LinuxBuildConfig(buildType: buildType);
      case BuildPlatform.web:
        return WebBuildConfig(buildType: buildType);
      default:
        return ObfuscatedBuildConfig(buildType: buildType);
    }
  }

  @override
  Future<void> _invoke() async {
    await _populateEnvMap();
    await BuildToolkit.build(getBuildConfig);
  }

  @override
  String get configName => 'App Builder';
}

class InitializeAppConfig extends IAppConfig {
  InitializeAppConfig({
    required super.isForced,
  });
  @override
  Future<void> _validate() async {
    if (!ProjectConfigs.hasPubspec) {
      cli
        ..printToConsole(
          'Pubspec file not found. cannot initialize hemend tools without pubspec file',
          isError: true,
        )
        ..printToConsole('run this command in root of the project');
      exit(64);
    }
  }

  @override
  Future<void> _invoke() async {
    await generateBasicCustomConfig(isForced);
    await ProductConfigSampleCreator.productConfigSampleCreator(isForced);
  }

  @override
  String get configName => 'Hemend Core initializer';
}

class VariableCheckConfig extends IAppConfig {
  VariableCheckConfig({
    required super.isForced,
    required this.generate,
  });
  final bool generate;
  @override
  Future<void> _validate() async {
    _checkHemspecYaml();
  }

  String generateClassForMap(EnvironmentParams params) {
    return '''
// ignore_for_file: constant_identifier_names, do_not_use_environment, lines_longer_than_80_chars
abstract class \$Environments {
  \$Environments._();
  ${params.entries.map((e) => "static const ${e.key} = ${envTypeDetector(e.value)}.fromEnvironment('${e.key}',defaultValue: ${envTypeDetector(e.value) == 'String' ? "'${e.value.replaceAll(r'$', '\\\$')}'" : e.value},);").join('\n\t')}
  static Map<String, dynamic> toMap() {
    return {
      ${params.entries.map((e) => "'${e.key}':${e.key}").join(',\n\t\t\t')}
    };
  }
}
''';
  }

  Map<String, dynamic> generateRunCommandSample(EnvironmentParams params) {
    return {
      'name': 'Hemend Run',
      'request': 'launch',
      'type': 'dart',
      'flutterMode': 'debug',
      'toolArgs': [
        '--multidex',
        ...params.entries.map(
          (e) => '"--dart-define=${e.key}=${e.value}"',
        ),
      ],
    };
  }

  @override
  Future<void> _invoke() async {
    await _populateEnvMap();
    cli.printToConsole(
      '''accessible values are:
${deInjector.get<Map<String, String>>().entries.map((e) => '${e.key} = <${envTypeDetector(e.value)}> (${e.value})').join('\n')} 

normalizer sheet:
${normalizerSheetMap.entries.map((e) => '${e.key} = "${e.value}"').join('\n')}
''',
    );

    if (generate) {
      // final vscodeFile = File('.vscode/launch.json');
      // final data = Map.from(jsonDecode(vscodeFile.readAsStringSync()));
      // final listOfConfigs = List<Map<String, dynamic>>.from(data['configurations']);
      // if (listOfConfigs.where((element) => element['name'] == 'Hemend Run').isNotEmpty) {
      //   cli.printToConsole('Hemend Run configuration already exists', isError: true);
      //   if (isForced) {
      //     cli.printToConsole('removing existing Hemend Run configuration', isError: true);
      //     listOfConfigs.removeWhere((element) => element['name'] == 'Hemend Run');
      //     listOfConfigs.add(generateRunCommandSample(deInjector.get<Map<String, String>>()));
      //     data['configurations'] = listOfConfigs;
      //     vscodeFile.writeAsStringSync(jsonEncode(data));
      //   }
      // } else {
      //   listOfConfigs.add(generateRunCommandSample(deInjector.get<Map<String, String>>()));
      //   data['configurations'] = listOfConfigs;
      //   vscodeFile.writeAsStringSync(jsonEncode(data));
      // }
      final dartFile = File('lib/generated_env.dart');
      if (isForced && dartFile.existsSync()) {
        cli.printToConsole(
          'generator ran with force mode it will rewrite the ${dartFile.path} file',
        );
      }
      if (isForced || !dartFile.existsSync()) {
        cli.runAsyncOn(
          'generating ${dartFile.path} ',
          () => dartFile.writeAsString(
            generateClassForMap(deInjector.get<Map<String, String>>()),
          ),
        );
      } else {
        cli.printToConsole(
          'found generated file in lib folder if you want to overwrite it use this command with --force(-f) flag',
        );
      }
    } else {
      cli.printToConsole(
        '''
use `hem env -g` to generate a dart file for values that will have current values as default values
to run app for debug without hem cli toolkit
''',
      );
    }
  }

  @override
  String get configName => 'Hemend Environment checker';
}

String envTypeDetector(String input) {
  if (input == 'false' || input == 'true') {
    return 'bool';
  }
  if (int.tryParse(input) != null) {
    return 'int';
  }
  return 'String';
}

class PubBuildRunnerConfig extends IAppConfig {
  PubBuildRunnerConfig({
    required this.watch,
    required this.deleteConflictingOutputs,
    required super.isForced,
  });
  final bool watch;
  final bool deleteConflictingOutputs;
  @override
  Future<void> _validate() async {
    _checkPubspecYaml();
  }

  @override
  Future<void> _invoke() {
    cli.verbosePrint('generating flutter_get pub spec yaml');
    const kFlutterGenPath = '.dart_tool/flutter_gen';
    Directory(kFlutterGenPath).createSync(recursive: true);
    File('$kFlutterGenPath/pubspec.yaml')
      ..createSync()
      ..writeAsStringSync('''dependencies: ''');

    return PubBuildRunnerToolkit.run(this);
  }

  @override
  String get configName => 'Build Runner';
}
