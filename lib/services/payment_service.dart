import 'dart:convert';

import 'package:boder/constants/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/constants/utils/errors_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class PaymentService extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();

  Future<Map<String, dynamic>?> processBatchPayout({
    required List<Map<String, dynamic>> payouts,
    required String remarks,
    required BuildContext context,
  }) async {
    final token = storage.read('token');
    print('🔍 PaymentService Batch Payout Debug:');
    print('   payouts count: ${payouts.length}');
    if (token == null) {
      toastService.showError(
        context: context, 
        message: 'No token found. Please login again.'
      );
      return null;
    }
    try {
      final url = ApiConfig.batchPayout;
      print('   URL: $url');
      final requestBody = {
        "payouts": payouts,
        "remarks": remarks
      };
      print('   Request Body: ${jsonEncode(requestBody)}');
      print('   Request Body (Formatted):');
      const encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(requestBody));
      final response = await post(
        url,
        requestBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('   Response Status: ${response.statusCode}');
      print('   Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      } else if (response.statusCode == 401) {
        storage.remove('token');
        storage.remove('user');
        toastService.showError(
          context: context,
          message: "Session expired. Please login again."
        );
        Get.offAllNamed('/');
        return null;
      } else {
        final errorMessage = extractErrorMessage(response);
        toastService.showError(context: context, message: errorMessage);
        return null;
      }
    } catch (e) {
      print('   Exception occurred: $e');
      toastService.showError(
        context: context,
        message: "Network error: ${e.toString()}"
      );
      return null;
    }
  }
}