import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

abstract class GitToolkit {
  static const List<String> _getLastCommitHash = [
    'log',
    '-n 1',
    '--pretty=format:"%H"',
  ];
  static Future<String> getLastCommitsHash() async {
    final result = await CommandLineTools.instance.runTaskInTerminal(
      name: 'Getting last commit hash',
      command: 'git',
      arguments: _getLastCommitHash,
    );
    return result.stdout;
  }
}
