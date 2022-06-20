import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:cli_util/cli_logging.dart';
import 'package:hemend_toolkit/core/dependency_injector/basic_dependency_injector.dart';
import 'package:hemend_toolkit/core/hemend_toolkit_config/cli_config.dart';

HemTerminal get cli => HemTerminal._();

class HemTerminal {
  final Logger logger = Logger.standard();
  HemTerminal._();

  void printToConsole(String message, {bool isError = false}) =>
      isError ? logger.stderr(message) : logger.stdout(message);

  String readLineFromConsole() => io.stdin.readLineSync() ?? '';
  Future<T> runAsyncOn<T>(
    String message,
    Future<T> Function() action,
  ) async {
    final progress = logger.progress(message);

    final result = await action();
    progress.finish(message: 'Done', showTiming: true);
    return result;
  }

  bool get _isVerbos => deInjector.get<HemConfig>().verbos;
  void verbosPrint(String message, {bool isError = false}) =>
      _isVerbos ? printToConsole(message, isError: isError) : null;
  Future<io.ProcessResult> runTaskInTerminal({
    required String name,
    required String command,
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool? runInShell,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    verbosPrint('running os task $name: $command ${arguments.join(' ')}');

    return runAsyncOn(
        name,
        () => Process.run(
              command,
              arguments,
              workingDirectory: workingDirectory,
              environment: environment,
              includeParentEnvironment: includeParentEnvironment,
              runInShell: runInShell ?? _isVerbos,
              stdoutEncoding: stdoutEncoding,
              stderrEncoding: stderrEncoding,
            ));
  }
}
