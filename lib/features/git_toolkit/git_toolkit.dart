import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

import '../../core/dependency_injector/basic_dependency_injector.dart';

abstract class GitToolkit {
  static List<String> get _getLastCommitHash => [
        'log',
        '-n 1',
        '--pretty=format:"%H"',
      ];
  static List<String> get _getLastCommitAuthorEmail => [
        'log',
        '-n 1',
        '--pretty=format:"%ae"',
      ];
  static Future<String> getLastCommitsHash() async {
    final result = await cli.runTaskInTerminal(
      name: "Getting last commit's hash",
      command: 'git',
      arguments: _getLastCommitHash,
    );
    final hash = result.stdout.toString().replaceAll('"', '');
    deInjector.get<Map<String, String>>().addAll({'hash': hash});
    return hash;
  }

  static Future<String> getLastCommitsAuthorEmail() async {
    final result = await cli.runTaskInTerminal(
      name: "Getting last commit's author's email",
      command: 'git',
      arguments: _getLastCommitAuthorEmail,
    );
    return result.stdout.toString().replaceAll('"', '');
  }
}
