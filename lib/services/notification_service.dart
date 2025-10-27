import 'dart:convert';
import 'package:boder/constants/api_config.dart';
import 'package:boder/views/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final storage = GetStorage();
  
  Map<String, String> get headers {
    final token = storage.read<String>('token');
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> sendToAllRegistered({
    required String title,
    required String message,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.sendToAllRegistered);
      
      final body = jsonEncode({
        'title': title,
        'message': message,
      });

      print('📤 Sending notification to all users');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  Future<bool> sendToUsers({
    required String title,
    required String message,
    required List<String> userIds,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.sendToUsers);
      
      final body = jsonEncode({
        'title': title,
        'message': message,
        'userIds': userIds,
      });

      print('📤 Sending notification to ${userIds.length} users');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification to users: $e');
      return false;
    }
  }

  Future<bool> sendToRiders({
    required String title,
    required String message,
    required List<String> riderIds,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.sendToRiders);
      
      final body = jsonEncode({
        'title': title,
        'message': message,
        'riderIds': riderIds,
      });

      print('📤 Sending notification to ${riderIds.length} riders');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification to riders: $e');
      return false;
    }
  }

  Future<bool> sendToSpecificUser({
    required String title,
    required String message,
    required String userId,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.sendToSpecificUser);
      
      final body = jsonEncode({
        'title': title,
        'message': message,
        'userId': userId,
      });

      print('📤 Sending notification to user: $userId');
      print('URL: $url');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification to user: $e');
      return false;
    }
  }

  Future<bool> sendToSpecificRider({
    required String title,
    required String message,
    required String riderId,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.sendToSpecificRider);
      
      final body = jsonEncode({
        'title': title,
        'message': message,
        'riderId': riderId,
      });

      print('📤 Sending notification to rider: $riderId');
      print('URL: $url');

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification to rider: $e');
      return false;
    }
  }

  Future<List<NotificationModel>> getNotificationHistory(BuildContext context) async {
    try {
      final url = Uri.parse(ApiConfig.notificationHistory);
      
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromMap(json)).toList();
      } else {
        print('❌ Failed to fetch notification history: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching notification history: $e');
      return [];
    }
  }
}