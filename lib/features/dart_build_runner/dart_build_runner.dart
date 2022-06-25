import 'package:hemend_toolkit/core/hemend_toolkit_config/app_config/app_config.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';

abstract class PubBuildRunnerToolkit {
  static Future<void> run(PubBuildRunnerConfig config) {
    final params = [
      'pub',
      'run',
      'build_runner',
    ];
    if (config.watch) {
      cli.verbosePrint('running on watch mode');
      params.add('watch');
    } else {
      cli.verbosePrint('running on build mode');
      params.add('build');
    }
    if (config.deleteConflictingOutputs || config.isForced) {
      cli.verbosePrint('removing conflicting outputs');
      params.add('--delete-conflicting-outputs');
    }
    return cli.runTaskInTerminal(
      name: 'Executing build runner',
      command: 'flutter',
      arguments: params,
    );
  }
}
