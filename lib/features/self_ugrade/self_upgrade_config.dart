part of '../../core/hemend_toolkit_config/app_config/app_config.dart';

class SelfUpgradeConfig extends IAppConfig {
  SelfUpgradeConfig({required super.isForced});

  @override
  String get configName => 'Self Upgrade Config';

  @override
  Future<void> _invoke() async {
    await cli.runTaskInTerminal(
      name: 'Self Upgrade',
      command: 'dart',
      arguments: [
        'pub',
        'global',
        'activate',
        'https://github.com/HemendCo/hemend_toolkit',
        '-s',
        'git',
        // '--git-path',
        // 'https://github.com/HemendCo/hemend_toolkit'
      ],
    );
  }
}
