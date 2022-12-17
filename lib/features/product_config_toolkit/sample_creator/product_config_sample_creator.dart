// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:json2yaml/json2yaml.dart';

import '../../../core/hemend_toolkit_config/cli_config.dart';
import '../../../core/io/command_line_toolkit/command_line_tools.dart';
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
# values here can be accessed in the app with dart environment variable
# run `hemend env -g` to generate abstract class to access constant values
# this will cause the values to take place in the app at compile time and not at runtime
# some of the values are not present here but they will be available in the app
# 
#
# ENV_CONFIG:
# API:
#   VERSION: "1"
#   SUFFIX: "IF HEMEND_CONFIG_DEBUG_LEVEL >= 1 ? /demo : \$empStr"
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
# ────────────────────────────────────────────────────────────────────────────────
#
# config parser will add 'CONFIG' prefix to each key to prevent collision with core configs
# e.g. ("BUILD_DATE_TIME", "LAST_GIT_COMMIT", "HEMEND_CONFIG_DEBUG_LEVEL", etc.)
# config parser will concat the nested keys to their root with '_' as separator
# in the yaml code snippet above, the key of app secret will be: "CONFIG_CRASHLYTIX_APP_SECRET"
#
# ─── QUERIES ────────────────────────────────────────────────────────────────────
#
# only works in `ENV_CONFIG` section of the config file
# to use queries inside other parts you need to link them to `ENV_CONFIG` section
# e.g.: \${ENV_CONFIG_API_VERSION}
# Supported Queries: 
# `IF` - IF <CONDITION> ? <VALUE FOR TRUE> : <VALUE FOR FALSE> 
# `CONDITION` => <ENV_CONFIG or CLI_PUBLIC_CONFIG> <OPERATOR> <VALUE>
# <OPERATOR> => operator can be one of (==,!=,<=,>=,<,>)
#
# `SWITCH` - SWITCH <ENV_CONFIG or CLI_PUBLIC_CONFIG> <CASE-0>:<VALUE-0>,<CASE-1>:<VALUE-1>,...,<DEFAULT>:<VALUE>
# parser will use UPPERCASE for case names and value of switch so its not case sensitive but values are case sensitive
# if no <DEFAULT> provided it will use the <ENV_CONFIG or CLI_PUBLIC_CONFIG>'s value as default
#
# ─── QUERIES LIMITS ─────────────────────────────────────────────────────────────
#
# if queries first parameter (<ENV_CONFIG or CLI_PUBLIC_CONFIG>) was not provided parser will set it intact
# so its value will be the query it self 
# e.g.: 
# if we don't provide `TEST` in `ENV_CONFIG` the result of below 
# IF TEST >= 1 ? 0 : 15
# will be it self (<TEST> => (String) "IF TEST >= 1 ? 0 : 15" )
#
# `IF query` reader uses `split(' ')` to split the query so you have to use spaces in the query to split its section
#
# `SWITCH query` reader uses `,` to split cases and uses `:` to detect key value pairs and it will throw in absence of `:`
#
# to insert a character or text that is reserved by query parsers you can use following keys:
#
${normalizerSheetMap.entries.map((e) => '# ${e.key} => "${e.value}"').join('\n')}
#
# ────────────────────────────────────────────────────────────────────────────────
#
# ─── ENV LIMITS ─────────────────────────────────────────────────────────────────
#
# Values will be parsed to their current type in `hem env -g` generator
# if you are using an integer for now but the value can be string some times
# you need to change generated dart file in order to prevent exception
#
# ────────────────────────────────────────────────────────────────────────────────
#
# DO NOT remove the <HEMEND_CONFIG> section its used to provide project settings
# to cli app and may throw in absence of required values
#
# ────────────────────────────────────────────────────────────────────────────────


''';

  static Future<Map<String, dynamic>> get _sampleAppConfig async => {
        'ENV_CONFIG': {
          'API': {
            'VERSION': '1',
            'SUFFIX': r'IF HEMEND_CONFIG_DEBUG_LEVEL >= 1 ? /demo : $empStr',
          },
          'RELEASE_TO': //
              'SWITCH HEMEND_CONFIG_BUILD_PLATFORM ANDROID:Building for android,IOS:its ios,DEFAULT:wow web?'
        },
        'HEMEND_CONFIG': {
          'UPLOAD': {
            'API': 'http://87.107.165.4:8081',
            'PATH': '/upload/outputs',
          },
          'NAME_FORMAT': //
              r'$n%-$v%-$build_type%-$YYYY%-$MM%-$DD%-$HH%,$mm%,$ss%',
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
              'ADDRESS': 'http://87.107.165.4:8081/crashlytix/log',
            },
          }
        }
      };

  static Future<void> productConfigSampleCreator([bool forced = false]) async {
    final file = File(kProductConfigFileName);

    if (forced || !file.existsSync()) {
      final buffer = StringBuffer()
        ..write(_comments)
        ..write(json2yaml(await _sampleAppConfig));

      await cli.runAsyncOn(
        'Generating hemspec.yaml config file', //
        (progress) => file.writeAsString(
          buffer.toString(),
        ),
      );
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
