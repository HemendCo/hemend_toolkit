import 'dart:io';

import 'package:hemend_toolkit/core/hemend_toolkit_config/cli_config.dart';
import 'package:hemend_toolkit/core/io/command_line_toolkit/command_line_tools.dart';
import 'package:json2yaml/json2yaml.dart';

import '../core/product_config_defaults.dart';
import '../read_config/product_config_reader.dart';

abstract class ProductConfigSampleCreator {
  static final _comments = '''
#
# ──────────────────────────────────────────────────────────────────────────
#   :::::: E N V I R O N E M T N S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────
#
# for more information about about environment variables use: `hem env`
# run `hemend env -g` to generate abstract class to access constant values
#
# add app config here (if any)
# values here can be accessed in the app from dart environment variable
# e.g.: String.fromEnvironment() and etc
# the only supported format is Map<String,String>
# supports nested maps but at the end all of them will be used as Map<String,String>
# e.g.:
# ENV_CONFIG:
# API:
#   VERSION: "1"
#   SUFFIX: "WHERE DEBUG_LEVEL >= 1 ? /demo : \$empStr"
#
# HEMEND_CONFIG:
#   NAME_FORMAT: "\$n%-\$v%-\$build_type%-\$YYYY%\\\$MM%\\\$DD%-\$HH%:\$mm%:\$ss%"
#   CLI_VERSION: 0.1
# ENV:
#   CRASHLYTIX:
#     APP:
#       SECRET: Add Crashlytix App Secret Here
#       ID: Add Crashlytix App ID Here
#     SERVER:
#       ADDRESS: "example.com/api/v\${ENV_CONFIG_API_VERSION}/crashlytix this will translate to example.com/api/v1/crashlytix"
#
# ENV_CONFIG is usable variables inside the hemspec config file
# in this section you can set variables which are static or they can have queries
# to get values from `hem cli` internal environment configs
# `WHERE query` reader uses `split(' ')` to split the query so you have to use spaces in the query to split its section
# `SWITCH query` reader uses `,` to split cases and uses `:` to detect key value pairs and it will throw in absence of `:`
# to insert a character or text that is reserved by query parsers you can use following keys:

${normalizerSheetMap.entries.map((e) => '# ${e.key} => "${e.value}"').join('\n')}

# config parser will add 'CONFIG' prefix to each key to prevent collision with core configs
# e.g. ("BUILD_TIME", "LAST_GIT_COMMIT", "DEBUG_LEVEL", etc.)
# config parser will concat the nested keys to their root with '_' as separator
# in the yaml code snippet above, the key of app secret will be: "CONFIG_CRASHLYTIX_APP_SECRET"

# DO NOT remove the default configs they are used by hemend core package
''';

  static Future<Map<String, dynamic>> get _sampleAppConfig async => {
        'ENV_CONFIG': {
          'API': {
            'VERSION': r'1',
            'SUFFIX': r'WHERE DEBUG_LEVEL >= 1 ? /demo : $empStr',
          },
          'RELEASE_TO': r"SWITCH REL_TO bazar:Bazar Ok,myket:Myket Ok,google:Google Ok,default:wow web?"
        },
        'HEMEND_CONFIG': {
          'UPLOAD': {
            'API': 'http://94.101.184.89:8081',
            'PATH': '/upload/outputs',
          },
          'NAME_FORMAT': r'$n%-$v%-$build_type%-$YYYY%-$MM%-$DD%-$HH%:$mm%:$ss%',
          'CLI_VERSION': InternalStaticInfo.CLI_VERSION,
        },
        'ENV': {
          'APP': {
            'API': {
              'BASE': r'example.com${ENV_CONFIG_API_SUFFIX}',
              'VERSION': r'${ENV_CONFIG_API_VERSION}',
            },
          },
          'CRASHLYTIX': {
            'APP': {
              'SECRET': 'Add Crashlytix App Secret Here',
              'ID': 'Add Crashlytix App ID Here',
            },
            'SERVER': {
              'ADDRESS':
                  r'example.com/api/v${ENV_CONFIG_API_VERSION}/crashlytix this will translate to example.com/api/v1/crashlytix',
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
      await cli.runAsyncOn('Generating hemspec.yaml config file', () => file.writeAsString(buffer.toString()));
    } else {
      cli.printToConsole(
        '''there is hemspec.yaml file in the project
if you want to reset the config file use --force or -f option
''',
        isError: true,
      );
      exit(1);
    }
  }
}
