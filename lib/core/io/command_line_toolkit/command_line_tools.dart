import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

class CLI {
  static CLI? _instance;

  static CLI get I {
    if (_instance == null) {
      throw 'CommandLineTools is not initialized';
    }
    return _instance!;
  }

  final Logger logger = Logger.standard();

  CLI() {
    if (_instance != null) {
      throw Exception('CommandLineTools already initialized');
    }
    _instance = this;
  }
  void printToConsole(Object? output) => print(output);
  String readLineFromConsole() => io.stdin.readLineSync() ?? '';
  Future<T> runAsyncOn<T>(
    String message,
    Future<T> Function() action,
  ) async {
    final mamad = logger.progress(message);
    final result = await action();
    mamad.finish(showTiming: true);
    return result;
  }

  Future<io.ProcessResult> runTaskInTerminal({
    required String name,
    required String command,
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    return await runAsyncOn(
        name,
        () => Process.run(
              command,
              arguments,
              workingDirectory: workingDirectory,
              environment: environment,
              includeParentEnvironment: includeParentEnvironment,
              runInShell: runInShell,
              stdoutEncoding: stdoutEncoding,
              stderrEncoding: stderrEncoding,
            ));
  }
}
