import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  
  // Auth
  static String get adminLogin => '$baseUrl/auth/admin/login';
  
  // Users
  static String get users => '$baseUrl/admin/users';
  static String deleteUser({String? userId, String? riderId}) {
    if ((userId == null && riderId == null) || (userId != null && riderId != null)) {
      throw ArgumentError('Either userId or riderId must be provided, but not both');
    }
    String url;
    if (userId != null) {
      url = '$baseUrl/admin/delete-user?userId=$userId';
    } else {
      url = '$baseUrl/admin/delete-user?riderId=$riderId';
    }
    return url;
  }
  static String userById(String id) => '$baseUrl/admin/users/$id';
  
  // Privileged Users
  static String get getAllPrivilegedUsers => '$baseUrl/admin/privileged-users'; 
  
  // Riders
  static String get riders => '$baseUrl/admin/riders';
  static String riderById(String id) => '$baseUrl/admin/riders/$id';
  static String approveRider(String id) => '$baseUrl/admin/approve_rider/$id';
  static String disapproveRider(String id) => '$baseUrl/admin/disapprove_rider/$id';

  // Trips
  static String get trips => '$baseUrl/admin/get-all-trips';

  // Wallets
  static String get wallets => '$baseUrl/wallet/all_wallets';
  static String get transactions => '$baseUrl/wallet/all_transactions';
  static String get payRiders => '$baseUrl/wallet/all_transactions';

  // Roles
  static String get roles => '$baseUrl/admin/roles';
  static String get assignRole => '$baseUrl/admin/assign_role';
  static String get removeRole => '$baseUrl/admin/remove_role';
  static String get createPrivilegeUser => '$baseUrl/admin/create-privileged-user';
  static String get statistics => '$baseUrl/admin/statistics';

  // Notifications
  static String get sendToAllRegistered => '$baseUrl/admin/send-to-all-registered';
  static String get sendToUsers => '$baseUrl/admin/send-to-users';
  static String get sendToRiders => '$baseUrl/admin/send-to-riders';
  static String get sendToSpecificUser => '$baseUrl/admin/send-to-user';
  static String get sendToSpecificRider => '$baseUrl/admin/send-to-rider';
  static String get notificationHistory => '$baseUrl/admin/notifications/history';
  static String notificationById(String id) => '$baseUrl/admin/notifications/$id';
}