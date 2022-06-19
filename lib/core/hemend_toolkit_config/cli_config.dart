// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HemConfig {
  final bool verbos;

  HemConfig(this.verbos);
}

class Request {
  final String path;
  final String method;
  final Map<String, dynamic> Function() bodyBuilder;
  final FutureOr<void> Function(Map<String, dynamic>) responseHandler;
  const Request({
    required this.path,
    required this.method,
    required this.bodyBuilder,
    required this.responseHandler,
  });
  Future<void> execute() async {
    final path = [
      InternalStaticInfo.SERVER_BASE_ADDRESS,
      this.path,
    ].join('/');
    final body = bodyBuilder();
    if (method == 'POST') {
      final request = await http.post(
        Uri.parse(path),
        body: body,
      );
      final result = jsonDecode(request.body);
      await responseHandler(result);
    }
  }
}

class InternalStaticInfo {
  static const CLI_VERSION = 0.1;

  /// set server path
  static const SERVER_BASE_ADDRESS = r'*/cli';

  static final VERSION_RESOLVE_REQUEST = Request(
    path: 'version',
    method: 'POST',
    bodyBuilder: () {
      return {
        'version': CLI_VERSION,
      };
    },
    responseHandler: (json) {
      throw json;
    },
  );
}
