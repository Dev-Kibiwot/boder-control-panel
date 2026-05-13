import 'package:devboder/constants/api_config.dart';
import 'package:devboder/services/toast_service.dart';
import 'package:devboder/constants/utils/errors_widget.dart';
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
      // Fetch all riders by paginating through all pages
      List allRiders = [];
      int page = 1;
      int totalPages = 1;

      do {
        final response = await get(
          '${ApiConfig.riders}?page=$page&pageSize=100',
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 && response.body != null) {
          final pageRiders = response.body['riders'] ?? [];
          allRiders.addAll(pageRiders);
          totalPages = response.body['totalPages'] ?? 1;
          page++;
        } else if (response.statusCode == 401) {
          storage.remove('token');
          storage.remove('user');
          toastService.showError(
            context: context,
            message: "Session expired. Please login again."
          );
          Get.offAllNamed('/');
          return;
        } else {
          toastService.showError(context: context, message: extractErrorMessage(response));
          return;
        }
      } while (page <= totalPages);

      riders = allRiders;
      return;
    } catch (e) {
      toastService.showError(context: context, message: "Network error: ${e.toString()}");
      return;
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
    try {
      final url = ApiConfig.deleteUser(riderId: riderId);
      final response = await delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
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
        final errorMessage = extractErrorMessage(response);
        toastService.showError(context: context, message: errorMessage);
        return false;
      }
    } catch (e) {
      toastService.showError(
        context: context,
        message: "Network error: Failed to delete rider: $e",
      );
      return false;
    }
  }
}