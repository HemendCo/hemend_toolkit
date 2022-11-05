import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

import '../../../core/dependency_injector/basic_dependency_injector.dart';
import '../../../core/hemend_toolkit_config/cli_config.dart';
import '../../../core/io/command_line_toolkit/command_line_tools.dart';
import '../platforms/android/build_configs/android_build_config.dart';
import '../platforms/ios/build_configs/ios_build_config.dart';
import 'contracts/build_config/build_config.dart';

abstract class BuildToolkit {
  static String toAndroidOutputPath(String appName) => 'outputs/$appName.apk';
  static String _buildAppName({
    required String format,
    required String suffix,
  }) {
    var appName = format;
    final config = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;

    final dt = deInjector.get<DateTime>();
    appName = appName.replaceAll(r'$n%', config['name']);
    appName = appName.replaceAll(r'$v%', 'v.${config['version']}');

    appName = appName.replaceAll(r'$YYYY%', dt.year.toString());
    appName = appName.replaceAll(
      r'$YY',
      dt.year.toString().substring(2),
    );
    appName = appName.replaceAll(r'$MM%', dt.month.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$DD%', dt.day.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$HH%', dt.hour.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$mm%', dt.minute.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$ss%', dt.second.toString().padLeft(2, '0'));
    appName = appName.replaceAll(r'$build_type%', suffix);
    final floatingInformations = deInjector.get<Map<String, String>>();
    for (final i in floatingInformations.entries) {
      appName = appName.replaceAll('\$${i.key}%', i.value);
    }

    return appName;
  }

  static Future<void> _buildCommand(IBuildConfig buildConfig) async {
    final params = await buildConfig.builderParams;
    final runResult = await cli.runTaskInTerminal(
      name: 'Building',
      command: buildConfig.builder,
      arguments: params,
    );

    if (runResult.exitCode != 0) {
      cli.printToConsole(
        'Build failed:\n${runResult.stdout}\n${runResult.stderr}',
        isError: true,
      );
      exit(runResult.exitCode);
    } else {
      cli.printToConsole(
        'Build Done:\n${runResult.stdout}\n${runResult.stderr}',
      );
      if (buildConfig is AndroidBuildConfig) {
        final finalApk = File(buildConfig.outputFileAddress);
        final appName = _buildAppName(
          suffix: buildConfig.buildType.name,
          format: buildConfig.nameFormat,
        );
        final outputPath = toAndroidOutputPath(appName);
        File(outputPath)
          ..createSync(recursive: true)
          ..deleteSync();
        finalApk.renameSync(outputPath);

        cli.printToConsole('Build output: $outputPath');

        if (deInjector.get<HemConfig>().isOnline) {
          final env = deInjector.get<Map<String, String>>();
          final apiBase = env['HEMEND_CONFIG_UPLOAD_API'];
          final apiPath = env['HEMEND_CONFIG_UPLOAD_PATH'];
          final url = '$apiBase$apiPath';
          final file = File(outputPath);
          final stdOuter = stdout.nonBlocking;
          stdOuter.write('Upload Begins');
          final request = Dio().postUri(
            Uri.parse(url),
            data: MultipartFile.fromFileSync(
              file.path,
            ),
            onSendProgress: (count, total) {
              stdOuter.write('\r\x1b[K');
              stdOuter.write('Uploading ${(count / total * 100).toStringAsFixed(2)}%');
            },
          );

          final response = await request;

          final responseString = response.data.toString();
          final responseJson = RegExp('\\[.*]') //
              .firstMatch(responseString)![0];
          cli.printToConsole(
            'Download Link : $apiBase/$responseJson'
                .replaceAll(
                  '[',
                  '',
                )
                .replaceAll(
                  ']',
                  '',
                ),
          );
        }
      }
      if (buildConfig is IosBuildConfig) {
        cli.printToConsole('Build output: ${buildConfig.outputFileAddress}');
      }
    }
  }

  static Future<void> build(IBuildConfig buildConfig) async {
    return _buildCommand(buildConfig);
  }
}
