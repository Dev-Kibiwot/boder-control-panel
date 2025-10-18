import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  // Auth
  static String get adminLogin => '$baseUrl/auth/admin/login';
  //users
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
  //privilage user
  static String get getAllPrivilegedUsers => '$baseUrl/admin/privileged-users'; 

  
  // Riders
  static String get riders => '$baseUrl/admin/riders';
  static String riderById(String id) => '$baseUrl/admin/riders/$id';
  static String approveRider(String id) => '$baseUrl/admin/approve_rider/$id';
  static String disapproveRider(String id) => '$baseUrl/admin/disapprove_rider/$id';

  //trips /api/admin/disapprove_rider/{id}
  static String get trips => '$baseUrl/admin/get-all-trips';

  //wallets
  static String get wallets => '$baseUrl/wallet/all_wallets';
  static String get transactions => '$baseUrl/wallet/all_transactions';
  static String get payRiders => '$baseUrl/wallet/all_transactions';

  //roles
  static String get roles => '$baseUrl/admin/roles';
  static String get assignRole => '$baseUrl/admin/assign_role';
  static String get removeRole => '$baseUrl/admin/remove_role';
  static String createPrivilegeUser = '$baseUrl/admin/create-privileged-user';
  static String get statistics => '$baseUrl/admin/statistics';
}

