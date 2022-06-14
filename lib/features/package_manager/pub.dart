import 'dart:io';

import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

abstract class PackageManager {
  static Future<void> validateAndUpgradePackages() async {
    await pubClean();
    await pubGet();
    await upgradePackages();
  }

  static Future<void> pubGet() async {
    final pubResult = await CommandLineTools.instance.runAsyncOn(
        'pub get',
        () => Process.run(
              'flutter',
              [
                'pub',
                'get',
              ],
            ));
    if (pubResult.exitCode != 0) {
      CommandLineTools.instance.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
      );
      throw Exception(
        'Error running pub get: ${pubResult.stderr}',
      );
    }
    CommandLineTools.instance.printToConsole(
      '''pub get done successfully''',
    );
  }

  static Future<void> pubClean() async {
    final pubResult = await CommandLineTools.instance.runAsyncOn(
        'pub clean',
        () => Process.run(
              'flutter',
              [
                'clean',
              ],
            ));
    if (pubResult.exitCode != 0) {
      CommandLineTools.instance.printToConsole(
        '''Error running flutter clean:
${pubResult.stderr}
''',
      );
      throw Exception('Error running flutter clean: ${pubResult.stderr}');
    }
    CommandLineTools.instance.printToConsole(
      '''flutter clean done''',
    );
  }

  static Future<void> upgradePackages() async {
    final pubResult = await CommandLineTools.instance.runAsyncOn(
        'pub upgrade',
        () => Process.run(
              'flutter',
              [
                'pub',
                'upgrade',
                '--major-versions',
              ],
            ));
    if (pubResult.exitCode != 0) {
      CommandLineTools.instance.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
      );
      throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    CommandLineTools.instance.printToConsole(
      '''pub upgrade done''',
    );
  }
}
