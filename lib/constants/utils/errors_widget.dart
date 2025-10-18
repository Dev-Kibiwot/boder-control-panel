import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';

String extractErrorMessage(dynamic error, {String fallback = "Something went wrong"}) {
  if (error is Response) {
    if (error.body is String) {
      try {
        final parsed = jsonDecode(error.body);
        return parsed['message'] ?? fallback;
      } catch (_) {
        return error.body;
      }
    } else if (error.body is Map) {
      return error.body['message'] ?? fallback;
    }
  }
  return error.toString();
}
