import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import '../../dependency_injector/basic_dependency_injector.dart';
import '../../hemend_toolkit_config/cli_config.dart';

final HemTerminal cli = HemTerminal._();

class HemTerminal {
  Logger _logger = Logger.standard();
  HemTerminal._();
  void useVerbosLogger() {
    _logger = Logger.verbose();
    printToConsole('using verbose logger config');
  }

  void printToConsole(String message, {bool isError = false}) =>
      isError ? _logger.stderr(message) : _logger.stdout(message);

  String readLineFromConsole() => io.stdin.readLineSync() ?? '';
  Future<T> runAsyncOn<T>(
    String message,
    Future<T> Function() action,
  ) async {
    final progress = _logger.progress(message);

    final result = await action();
    progress.finish(message: 'Done', showTiming: true);
    return result;
  }

  bool get _isVerbos => deInjector.getSafe<HemConfig>()?.verbose ?? false;
  void verbosePrint(String message, {bool isError = false}) =>
      _isVerbos ? printToConsole(message, isError: isError) : null;
  Future<io.ProcessResult> runTaskInTerminal({
    required String name,
    required String command,
    required List<String> arguments,
    bool isAdminCmd = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    verbosePrint('running os task $name: $command ${arguments.join(' ')}');

    _ProcessParams params;
    if (Platform.isLinux || Platform.isMacOS) {
      params = _ProcessParams(
        isAdminCmd ? 'sudo' : '/bin/sh',
        [
          if (isAdminCmd) '/bin/sh',
          '-c',
          [command, ...arguments].join(' '),
        ],
      );
    } else if (Platform.isWindows) {
      params = _ProcessParams(
        'cmd',
        [
          '/c',
          [command, ...arguments].join(' '),
        ],
      );
    } else {
      throw UnsupportedError('current os is not supported');
    }
    final process = await Process.start(
      params.exe,
      params.args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
    );

    final stdOut = await process.stdout.fold<List<String>>(
      <String>[],
      (previous, element) {
        final newVal = String.fromCharCodes(element);
        cli.printToConsole(newVal);
        return <String>[
          ...previous,
          newVal,
        ];
      },
    );
    final stdErr = await process.stderr.fold<List<String>>(
      <String>[],
      (previous, element) {
        final newVal = String.fromCharCodes(element);
        cli.printToConsole(newVal, isError: true);
        return <String>[
          ...previous,
          newVal,
        ];
      },
    );
    final exitCode = await process.exitCode;

    verbosePrint(
      '''
exit code: ${exitCode}
result:
${stdOut.join('')}

error:
${stdErr.join()}
''',
    );
    return io.ProcessResult(
      process.pid,
      exitCode,
      stdOut.join(),
      stdErr.join(),
    );
  }
}

class _ProcessParams {
  final String exe;
  final List<String> args;

  _ProcessParams(this.exe, this.args);
}
