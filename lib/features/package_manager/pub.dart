import 'dart:io';

import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

abstract class PackageManager {
  static Future<void> validateAndUpgradePackages() async {
    await pubClean();
    await pubGet();
    await upgradePackages();
  }

  static Future<void> pubGet() async {
    final pubResult = await HemTerminal.I.runTaskInTerminal(
      name: 'pub get',
      command: 'flutter',
      arguments: [
        'pub',
        'get',
      ],
    );
    if (pubResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
        isError: true,
      );
      // throw Exception(
      //   'Error running pub get: ${pubResult.stderr}',
      // );
      exit(pubResult.exitCode);
    }
    HemTerminal.I.printToConsole(
      '''pub get done successfully''',
    );
  }

  static Future<void> pubClean() async {
    final pubResult = await HemTerminal.I.runTaskInTerminal(
      name: 'pub clean',
      command: 'flutter',
      arguments: [
        'clean',
      ],
    );
    if (pubResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running flutter clean:
${pubResult.stderr}
''',
        isError: true,
      );
      exit(pubResult.exitCode);
      // throw Exception('Error running flutter clean: ${pubResult.stderr}');
    }
    // HemTerminal.I.printToConsole(
    //   '''flutter clean done''',
    // );
  }

  static Future<void> upgradePackages() async {
    final pubResult = await HemTerminal.I.runTaskInTerminal(
      name: 'pub upgrade',
      command: 'flutter',
      arguments: [
        'pub',
        'upgrade',
      ],
    );
    if (pubResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
        isError: true,
      );
      exit(pubResult.exitCode);
      // throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    final majorResult = await HemTerminal.I.runTaskInTerminal(
      name: 'pub upgrade',
      command: 'flutter',
      arguments: [
        'pub',
        'upgrade',
        '--major-versions',
      ],
    );
    if (majorResult.exitCode != 0) {
      HemTerminal.I.printToConsole(
        '''Error running pub get:
${majorResult.stderr}
''',
        isError: true,
      );
      exit(majorResult.exitCode);
      // throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    // HemTerminal.I.printToConsole(
    //   '''pub upgrade done''',
    // );
  }
}
