import 'dart:io';

import 'package:hemend_toolkit/features/product_config_toolkit/read_config/product_config_reader.dart';
import 'package:hemend_toolkit/features/product_config_toolkit/versioning/versioning.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../../../core/dependency_injector/basic_dependency_injector.dart';
import '../../../core/hemend_toolkit_config/cli_config.dart';
import '../../../core/io/command_line_toolkit/command_line_tools.dart';
import '../../../core/io/multipart_request.dart' as http;
import '../../git_toolkit/git_toolkit.dart';
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
    // final config = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    print('Secret: ${deInjector.get<Map<String, String>>()}');
    final dt = deInjector.get<DateTime>();
    appName = appName.replaceAll(r'$n%', deInjector.get<Map<String, String>>()['APP_CONFIG_NAME']!);
    appName = appName.replaceAll(r'$v%', 'v.${deInjector.get<Map<String, String>>()['APP_CONFIG_VERSION']}');

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
    try {
      Directory(
        'outputs/',
      ).createSync(recursive: true);
      readPubspecInfo();
    } catch (e) {
      print(e);
    }
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
        finalApk.renameSync(outputPath);

        cli.printToConsole('Build output: $outputPath');

        if (deInjector.get<HemConfig>().isOnline) {
          await cli.runAsyncOn('Uploading Output', (progress) async {
            stdout.write('Upload Begins.');
            final env = deInjector.get<Map<String, String>>();
            final apiBase = env['HEMEND_CONFIG_UPLOAD_API'];
            final apiPath = env['HEMEND_CONFIG_UPLOAD_PATH'];
            final url = '$apiBase$apiPath';
            final timer = Stopwatch();
            final request = http.MultipartRequestProgress(
              'POST',
              Uri.parse(url),
              onProgress: (bytes, totalBytes) {
                if (timer.isRunning != true) {
                  timer.start();
                }
                final time = cli.elapsedTime;
                var prefix = '';
                if (time != null) {
                  prefix = '${formatter(time)} ';
                }
                final sentMb = bytes / 1000000;
                final sizeText = '${sentMb.toStringAsFixed(1)}/${(totalBytes / 1000000).toStringAsFixed(1)}Mb';
                final percentage = '''${((bytes / totalBytes) * 100).toStringAsFixed(2)}%''';
                final passedTime = timer.elapsed.inMilliseconds / 1000;
                final speedApprox = (sentMb / passedTime).toStringAsFixed(2);
                final eta = (((totalBytes / 1000000) - sentMb) / double.parse(speedApprox)).toStringAsFixed(3);
                stdout.write(
                  '''\x1B[2K\r${prefix}Upload Progress: $percentage $sizeText ~${speedApprox}Mbps ~${eta}s left''',
                );
              },
            );
            final file = File(outputPath);
            final apk = await http.MultipartFile.fromPath(
              'file_field',
              file.path,
            );

            request.files.add(apk);

            final response = await request.send();

            final responseData = await response.stream.toBytes();
            timer.stop();
            stdout.write('\x1B[2K\r');
            final responseString = String.fromCharCodes(responseData);
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
          });
        }
      }
      if (buildConfig is IosBuildConfig) {
        cli.printToConsole('Build output: ${buildConfig.outputFileAddress}');
      }
      final version = deInjector.get<Map<String, String>>()['APP_CONFIG_VERSION'].toString();
      final name = deInjector.get<Map<String, String>>()['APP_CONFIG_NAME'].toString();
      final platform = deInjector.get<Map<String, String>>()['HEMEND_CONFIG_BUILD_PLATFORM'].toString();
      final mode = deInjector.get<Map<String, String>>()['HEMEND_CONFIG_BUILD_MODE'].toString();

      await GitToolkit.addReleaseTag(name, version, '$mode-$platform');
    }
  }

  static Future<void> build(IBuildConfig buildConfig) async {
    return _buildCommand(buildConfig);
  }
}

String formatter(Duration duration) {
  final buffer = StringBuffer();
  if (duration.inMinutes > 0) {
    buffer.write('${duration.inMinutes}m ');
  }
  buffer
    ..write(((duration.inMilliseconds / 1000) % 60).toStringAsFixed(3))
    ..write('s');
  final output = buffer.toString().padLeft(11);
  return '[$output]';
}
