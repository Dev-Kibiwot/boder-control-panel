import 'package:boder/constants/utils/errors_widget.dart';
import 'package:boder/models/privillage_user.dart';
import 'package:boder/services/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PrivilegedUserService extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();

  Future<PrivilegedUsersResponse> getAllPrivilegedUsers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = storage.read('token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await get(
      ApiConfig.getAllPrivilegedUsers,
      headers: requestHeaders,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get privileged users: ${response.statusText}',
      );
    }
    return PrivilegedUsersResponse.fromJson(response.body);
  }

  Future<Response> createPrivilegeUser({
    required String email,
    required String password,
    String? phoneNumber,
    String? firstname,
    String? lastname,
  }) async {
    final token = storage.read('token');
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final requestData = {
      'email': email,
      'password': password,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (firstname != null && firstname.isNotEmpty) 'firstname': firstname,
      if (lastname != null && lastname.isNotEmpty) 'lastname': lastname,
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

  Future<PrivilegedUser> getPrivilegedUserById(String userId) async {
    final token = storage.read('token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await get(
      '${ApiConfig.getAllPrivilegedUsers}/$userId',
      headers: requestHeaders,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get privileged user: ${response.statusText}',
      );
    }
    return PrivilegedUser.fromJson(response.body['data']);
  }

  Future<bool> deletePrivillageUser(String userId, BuildContext context) async {
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