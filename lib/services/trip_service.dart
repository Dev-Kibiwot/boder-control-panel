import 'package:devboder/constants/utils/errors_widget.dart';
import 'package:devboder/constants/api_config.dart';
import 'package:devboder/models/trip_model.dart';
import 'package:devboder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class TripService extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();
  List trips = [];

  bool get isAuthenticated {
    final token = storage.read('token');
    return token != null && token.toString().isNotEmpty;
  }

  void _handleAuthError(BuildContext context) {
    storage.remove('token');
    storage.remove('user');
    toastService.showError(context: context, message: "Session expired. Please login again.");
    Get.offAllNamed('/');
  }

  Future<void> getTrips(BuildContext context) async {
    if (!isAuthenticated) {
      _handleAuthError(context);
      return;
    }
    final token = storage.read('token');
    try {
      final response = await get(
        ApiConfig.trips, 
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        _handleSuccessResponse(response.body);
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          await getTrips(context);
        } else {
          _handleAuthError(context);
        }
      } else {
        final errorMsg = extractErrorMessage(response);
        toastService.showError(context: context, message: errorMsg);
      }
    } catch (e) {
      toastService.showError(context: context, message: "Network error: $e");
    }
  }

  void _handleSuccessResponse(dynamic responseBody) {
    if (responseBody == null) {
      trips = [];
      return;
    }
    try {      
      if (responseBody is Map<String, dynamic>) {
        if (responseBody.containsKey('success')) {
          if (responseBody['success'] == true) {
            dynamic tripsData = responseBody['trips'] ??  responseBody['data'] ?? responseBody['results'] ??  responseBody['items'] ?? [];
            if (tripsData is List) {
              trips = tripsData;
            } else {
              trips = [];
            }
          } else {
            final errorMessage = responseBody['message'] ?? responseBody['error'] ?? 'API returned success: false';
            trips = [];
            throw Exception(errorMessage);
          }
        } else {
          if (responseBody.containsKey('trips') || 
              responseBody.containsKey('data') || 
              responseBody.containsKey('results')) {
            dynamic tripsData = responseBody['trips'] ?? responseBody['data'] ?? responseBody['results'] ?? [];
            if (tripsData is List) {
              trips = tripsData;
            } else {
              trips = [];
            }
          } else {
            trips = [];
          }
        }
      } else if (responseBody is List) {
        trips = responseBody;
      } else {
        trips = [];
      }
    } catch (e) {
      trips = [];
      rethrow;
    }
  }
  
  Future<List<Trip>> getParsedTrips(BuildContext context) async {
    await getTrips(context);
    List<Trip> parsedTrips = [];
    for (int i = 0; i < trips.length; i++) {
      try {
        Map<String, dynamic> tripMap;
        if (trips[i] is Map) {
          tripMap = Map<String, dynamic>.from(trips[i] as Map);
        } else {
          continue;
        }
        final trip = Trip.fromMap(tripMap);
        parsedTrips.add(trip);
      } catch (e) {
      }
    }
    return parsedTrips;
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = storage.read('refresh_token');
      if (refreshToken == null) {
        return false;
      }
      final response = await post(
        '${ApiConfig.baseUrl}/auth/refresh',
        {'refresh_token': refreshToken},
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 && response.body['token'] != null) {
        storage.write('token', response.body['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}