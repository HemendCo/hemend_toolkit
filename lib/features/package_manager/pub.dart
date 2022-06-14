import 'dart:io';

import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

abstract class PackageManager {
  static Future<void> validateAndUpgradePackages() async {
    await pubClean();
    await pubGet();
    await upgradePackages();
  }

  static Future<void> pubGet() async {
    final pubResult = await HemTerminal.I.runAsyncOn(
        'pub get',
        () => Process.run(
              'flutter',
              [
                'pub',
                'get',
              ],
            ));
    if (pubResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
      );
      throw Exception(
        'Error running pub get: ${pubResult.stderr}',
      );
    }
    HemTerminal.I.printToConsole(
      '''pub get done successfully''',
    );
  }

  static Future<void> pubClean() async {
    final pubResult = await HemTerminal.I.runAsyncOn(
        'pub clean',
        () => Process.run(
              'flutter',
              [
                'clean',
              ],
            ));
    if (pubResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running flutter clean:
${pubResult.stderr}
''',
      );
      throw Exception('Error running flutter clean: ${pubResult.stderr}');
    }
    HemTerminal.I.printToConsole(
      '''flutter clean done''',
    );
  }

  static Future<void> upgradePackages() async {
    final pubResult = await HemTerminal.I.runAsyncOn(
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
      HemTerminal.I.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
      );
      throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    HemTerminal.I.printToConsole(
      '''pub upgrade done''',
    );
  }
}
