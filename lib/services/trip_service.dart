import 'package:boder/constants/utils/errors_widget.dart';
import 'package:boder/constants/api_config.dart';
import 'package:boder/models/trip_model.dart';
import 'package:boder/services/toast_service.dart';
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
        print('Trips loaded: ${trips.length}'); // Debug log
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry the request with new token
          await getTrips(context);
        } else {
          _handleAuthError(context);
        }
      } else {
        final errorMsg = extractErrorMessage(response);
        print('API Error: $errorMsg'); // Debug log
        toastService.showError(context: context, message: errorMsg);
      }
    } catch (e, stackTrace) {
      print('Exception in getTrips: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      toastService.showError(context: context, message: "Network error: $e");
    }
  }

  void _handleSuccessResponse(dynamic responseBody) {
    if (responseBody == null) {
      print('Response body is null'); // Debug log
      trips = [];
      return;
    }
    
    try {
      print('Processing response body: ${responseBody.runtimeType}'); // Debug log
      
      if (responseBody is Map<String, dynamic>) {
        print('Response keys: ${responseBody.keys.toList()}'); // Debug log
        
        // Check if it's a success response
        if (responseBody.containsKey('success')) {
          if (responseBody['success'] == true) {
            // Look for trips data in various possible keys
            dynamic tripsData = responseBody['trips'] ?? 
                               responseBody['data'] ?? 
                               responseBody['results'] ?? 
                               responseBody['items'] ??
                               [];
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