import 'package:boder/constants/utils/errors_widget.dart';
import 'package:boder/constants/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class UserService extends GetConnect {
  final storage = GetStorage();
  List users = [];
  ToastService toastService = ToastService();

  Future<void> getUsers(BuildContext context) async {
    final token = storage.read('token');
    try {
      final response = await get(
        ApiConfig.users,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (response.body != null) {
          users = response.body['users'] ?? [];
        } 
      } else {
        if (response.statusCode == 401) {
          storage.remove('token');
          storage.remove('user');
          toastService.showError(
            context: context,
            message: "Session expired. Please login again."
          );
          Get.offAllNamed('/');
        }
      }
    } catch (e) {
      toastService.showError(context: context, message: "Network error: ${e.toString()}");
    }
  }
  Future<bool> deleteUser(String userId, BuildContext context) async {
  final token = storage.read('token');
  // Debug logging
  print('🔍 Delete User Debug:');
  print('   userId: $userId');
  print('   token exists: ${token != null}');
  
  try {
    // Build URL and log it
    final url = ApiConfig.deleteUser(userId: userId);
    print('   URL: $url');
    
    final response = await delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('   Response Status: ${response.statusCode}');
    print('   Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 401) {
      storage.remove('token');
      storage.remove('user');
      toastService.showError(
        context: context,
        message: "Session expired. Please login again.",
      );
      Get.offAllNamed('/');
      return false;
    } else if (response.statusCode == 404) {
      print('   404 Error Details: User not found with userId: $userId');
      toastService.showError(
        context: context,
        message: "User not found. The user may have already been deleted or the ID is incorrect.",
      );
      return false;
    } else if (response.statusCode == 403) {
      toastService.showError(
        context: context,
        message: "You don't have permission to delete this user.",
      );
      return false;
    } else {
      print('   Unexpected status code: ${response.statusCode}');
      final errorMessage = extractErrorMessage(response);
      toastService.showError(context: context, message: errorMessage);
      return false;
    }
  } catch (e) {
    print('   Exception occurred: $e');
    toastService.showError(
      context: context,
      message: "Network error: Failed to delete user: $e",
    );
    return false;
  }
}
}