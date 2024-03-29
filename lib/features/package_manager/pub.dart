import 'dart:io';

import '../../core/io/command_line_toolkit/command_line_tools.dart';

abstract class PackageManager {
  static Future<void> validateAndUpgradePackages([String? workingPath]) async {
    await pubClean(workingPath);
    await pubGet(workingPath);
    await upgradePackages(workingPath);
  }

  static Future<void> pubGet([String? workingPath]) async {
    final pubResult = await cli.runTaskInTerminal(
      name: 'pub get',
      command: 'flutter',
      workingDirectory: workingPath,
      arguments: [
        'pub',
        'get',
      ],
    );
    if (pubResult.exitCode != 0) {
      cli.printToConsole(
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
    cli.printToConsole(
      '''pub get done successfully''',
    );
  }

  static Future<void> pubClean([String? workingPath]) async {
    final pubResult = await cli.runTaskInTerminal(
      name: 'pub clean',
      command: 'flutter',
      workingDirectory: workingPath,
      arguments: [
        'clean',
      ],
    );
    if (pubResult.exitCode != 0) {
      cli.printToConsole(
        '''Error running flutter clean:
${pubResult.stderr}
''',
        isError: true,
      );
      exit(pubResult.exitCode);
      // throw Exception('Error running flutter clean: ${pubResult.stderr}');
    }
    // cli.printToConsole(
    //   '''flutter clean done''',
    // );
  }

  static Future<void> upgradePackages([String? workingPath]) async {
    final pubResult = await cli.runTaskInTerminal(
      name: 'pub upgrade',
      command: 'flutter',
      workingDirectory: workingPath,
      arguments: [
        'pub',
        'upgrade',
      ],
    );
    if (pubResult.exitCode != 0) {
      cli.printToConsole(
        '''Error running pub get:
${pubResult.stderr}
''',
        isError: true,
      );
      exit(pubResult.exitCode);
      // throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    final majorResult = await cli.runTaskInTerminal(
      name: 'pub upgrade',
      command: 'flutter',
      arguments: [
        'pub',
        'upgrade',
        '--major-versions',
      ],
    );
    if (majorResult.exitCode != 0) {
      cli.printToConsole(
        '''Error running pub get:
${majorResult.stderr}
''',
        isError: true,
      );
      exit(majorResult.exitCode);
      // throw Exception('Error running pub upgrade: ${pubResult.stderr}');
    }
    // cli.printToConsole(
    //   '''pub upgrade done''',
    // );
  }
}
