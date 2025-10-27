import 'package:boder/constants/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/constants/utils/errors_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class RidersServices extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();
  List riders = [];

  Future<void> getRiders(BuildContext context) async {
    final token = storage.read('token');
    try {
      final response = await get(
        ApiConfig.riders,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (response.body != null) {
          riders = response.body['riders'] ?? [];
        } 
      } else if (response.statusCode == 401) {
        storage.remove('token');
        storage.remove('user');
        toastService.showError(
          context: context,
          message: "Session expired. Please login again."
        );
        Get.offAllNamed('/');
      } else {
        toastService.showError(context: context, message: extractErrorMessage(response));
      }
    } catch (e) {
      toastService.showError(context: context, message: "Network error: ${e.toString()}");
    }
  }

  Future<void> approveRider(String riderId, BuildContext context) async {
  final token = storage.read('token');
  if (token == null) {
    toastService.showError(context: context, message: 'No token found. Please login again.');
    return;
  }
  try {
    final response = await put(
      ApiConfig.approveRider(riderId),
      {
        "isAvailable": true,
        "lat": 0.0, 
        "lng": 0.0
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      toastService.showSuccess(context: context, message: "Rider approved successfully");
    } else if (response.statusCode == 401) {
      storage.remove('token');
      storage.remove('user');
      toastService.showError(
        context: context,
        message: "Session expired. Please login again."
      );
      Get.offAllNamed('/');
    } else {
      final errorMessage = extractErrorMessage(response);
      toastService.showError(context: context, message: errorMessage);
    }
  } catch (e) {
    toastService.showError(context: context, message: "Network error: ${e.toString()}");
  }
}

 Future<void> disapproveRider(String riderId, BuildContext context) async {
    final token = storage.read('token');
    if (token == null) {
      toastService.showError(context: context, message: 'No token found. Please login again.');
      return;
    }
    try {
      final response = await put(
        ApiConfig.disapproveRider(riderId),
        {
          "isAvailable": false,
          "lat": 0.0,
          "lng": 0.0
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
      } else if (response.statusCode == 401) {
        storage.remove('token');
        storage.remove('user');
        toastService.showError(
          context: context,
          message: "Session expired. Please login again."
        );
        Get.offAllNamed('/');
      } else {
        final errorMessage = extractErrorMessage(response);
        toastService.showError(context: context, message: errorMessage);
      }
    } catch (e) {
      toastService.showError(context: context, message: "Error: ${e.toString()}");
    }
  }

  Future<bool> deleteUser({
    required String riderId,
    required BuildContext context,
  }) async {
    final token = storage.read('token');
    
    // Debug logging
    print('🔍 RidersService Delete User Debug:');
    print('   riderId: $riderId');
    print('   token exists: ${token != null}');
    
    try {
      // Build URL and log it
      final url = ApiConfig.deleteUser(riderId: riderId);
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
        print('   404 Error Details: Rider not found with riderId: $riderId');
        toastService.showError(
          context: context,
          message: "Rider not found. The rider may have already been deleted or the ID is incorrect.",
        );
        return false;
      } else if (response.statusCode == 403) {
        toastService.showError(
          context: context,
          message: "You don't have permission to delete this rider.",
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
        message: "Network error: Failed to delete rider: $e",
      );
      return false;
    }
  }
}