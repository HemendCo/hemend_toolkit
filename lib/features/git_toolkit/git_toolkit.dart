import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

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
    final result = await HemTerminal.I.runTaskInTerminal(
      name: "Getting last commit's hash",
      command: 'git',
      arguments: _getLastCommitHash,
    );
    return result.stdout.toString().replaceAll('"', '');
  }

  static Future<String> getLastCommitsAuthorEmail() async {
    final result = await HemTerminal.I.runTaskInTerminal(
      name: "Getting last commit's author's email",
      command: 'git',
      arguments: _getLastCommitAuthorEmail,
    );
    return result.stdout.toString().replaceAll('"', '');
  }
}
