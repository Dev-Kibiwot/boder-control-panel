import 'dart:io';

import 'package:boder/constants/utils/errors_widget.dart';
import 'package:boder/services/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();

  Future<Response> adminLogin(String email, String password, BuildContext context) async {
    final response = await post(
      ApiConfig.adminLogin,
      {
        'email': email,
        'password': password,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200 && response.body['data']?['token'] != null) {
      final token = response.body['data']['token'];
      await storage.write('token', token);
    } else {
      toastService.showError(context: context, message: extractErrorMessage(response));
    }
    return response;
  }
 
  Future<Response> createPrivilegeUser({
  required String email,
  required String firstName,
  required String lastNmae,
  required String password,
  required String phoneNumber,
}) async {
  final token = storage.read('token');
  if (token == null) {
    throw Exception('No authentication token found');
  }
  
  final requestData = {
    'email': email,
    'password': password,
    'firstname' : firstName,
    'lastname' : lastNmae,
    'phoneNumber': phoneNumber,
  };
  
  final requestHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await post(
    ApiConfig.createPrivilegeUser,
    requestData,
    headers: requestHeaders,
  );
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(
      'Failed to create privilege user: ${response.statusText}',
    );
  }

  return response;
}
}
