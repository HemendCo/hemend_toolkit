import 'dart:io';

import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:json2yaml/json2yaml.dart';

import '../core/product_config_defaults.dart';

abstract class ProductConfigSampleCreator {
  static const _comments = '''
# add app config here (if any)
# values here can be accessed in the app from dart environment variable
# e.g.: String.fromEnvironment() and etc
# the only supported format is Map<String,String>
# supports nested maps but at the end all of them will be used as Map<String,String>
# e.g.:
# env:
#   CRASHLYTIX:
#     APP:
#       SECRET: Add Crashlytix App Secret Here
#       ID: Add Crashlytix App ID Here
#     SERVER:
#       ADDRESS: Add Crashlytix Server Address Here
# config parser will add 'CONFIG' prefix to each key to prevent collision with core configs
# e.g. ("BUILD_TIME", "LAST_GIT_COMMIT", "DEBUG_LEVEL", etc.)
# config parser will concat the nested keys to their root with '_' as separator
# in the yaml code snippet above, the key of app secret will be: "CONFIG_CRASHLYTIX_APP_SECRET"

# DO NOT remove the default configs they are used by hemend core package

''';

  static Future<Map<String, dynamic>> get _sampleAppConfig async => {
        'HEMEND_CONFIG': {
          'NAME_FORMAT': r'$n%-$v%-$build_type%-$YYYY%\\$MM%\\$DD%-$HH%:$mm%:$ss%',
        },
        'ENV': {
          'CRASHLYTIX': {
            'APP': {
              'SECRET': 'Add Crashlytix App Secret Here',
              'ID': 'Add Crashlytix App ID Here',
            },
            'SERVER': {
              'ADDRESS': 'Add Crashlytix Server Address Here',
            },
          }
        }
      };

  static Future<void> productConfigSampleCreator([bool forced = false]) async {
    final file = File(kProductConfigFileName);

    if (forced || !file.existsSync()) {
      final buffer = StringBuffer();
      buffer.write(_comments);
      buffer.write(json2yaml(await _sampleAppConfig));
      Directory(
        'outputs/',
      ).createSync(recursive: true);
      await HemTerminal.I
          .runAsyncOn('Generating hemspec.yaml config file', () => file.writeAsString(buffer.toString()));
    } else {
      HemTerminal.I.printToConsole(
        '''there is hemspec.yaml file in the project
if you want to reset the config file use --force or -f option
''',
        isError: true,
      );
      exit(1);
    }
  }
}
