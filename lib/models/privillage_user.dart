class PrivilegedUser {
  final String identityId;
  final String userId;
  final String email;
  final String userName;
  final String phone;
  final String firstname;
  final String lastname;
  final String userType;
  final bool emailConfirmed;
  final bool mustChangePassword;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? lastLoginTime;
  final DateTime? lastLogoutTime;
  final String originalUserType;

  PrivilegedUser({
    required this.identityId,
    required this.userId,
    required this.email,
    required this.userName,
    required this.phone,
    required this.firstname,
    required this.lastname,
    required this.userType,
    required this.emailConfirmed,
    required this.mustChangePassword,
    required this.roles,
    this.createdAt,
    this.lastLoginTime,
    this.lastLogoutTime,
    required this.originalUserType,
  });

  factory PrivilegedUser.fromJson(Map<String, dynamic> json) {
    return PrivilegedUser(
      identityId: json['identity_id'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      phone: json['phone'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      userType: json['userType'] ?? '',
      emailConfirmed: json['emailConfirmed'] ?? false,
      mustChangePassword: json['mustChangePassword'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      lastLoginTime: json['last_login_time'] != null 
          ? DateTime.parse(json['last_login_time']) 
          : null,
      lastLogoutTime: json['last_logout_time'] != null 
          ? DateTime.parse(json['last_logout_time']) 
          : null,
      originalUserType: json['originalUserType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity_id': identityId,
      'user_id': userId,
      'email': email,
      'userName': userName,
      'phone': phone,
      'firstname': firstname,
      'lastname': lastname,
      'userType': userType,
      'emailConfirmed': emailConfirmed,
      'mustChangePassword': mustChangePassword,
      'roles': roles,
      'created_at': createdAt?.toIso8601String(),
      'last_login_time': lastLoginTime?.toIso8601String(),
      'last_logout_time': lastLogoutTime?.toIso8601String(),
      'originalUserType': originalUserType,
    };
  }

  @override
  String toString() {
    return 'PrivilegedUser{identityId: $identityId, userId: $userId, email: $email, userName: $userName, phone: $phone, firstname: $firstname, lastname: $lastname, userType: $userType, emailConfirmed: $emailConfirmed, mustChangePassword: $mustChangePassword, roles: $roles, createdAt: $createdAt, lastLoginTime: $lastLoginTime, lastLogoutTime: $lastLogoutTime, originalUserType: $originalUserType}';
  }
}

class PrivilegedUsersResponse {
  final bool success;
  final String message;
  final int totalPrivilegedUsers;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<PrivilegedUser> privilegedUsers;

  PrivilegedUsersResponse({
    required this.success,
    required this.message,
    required this.totalPrivilegedUsers,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.privilegedUsers,
  });

  factory PrivilegedUsersResponse.fromJson(Map<String, dynamic> json) {
    return PrivilegedUsersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalPrivilegedUsers: json['totalPrivilegedUsers'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
      privilegedUsers: (json['privilegedUsers'] as List<dynamic>? ?? [])
          .map((user) => PrivilegedUser.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'totalPrivilegedUsers': totalPrivilegedUsers,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'privilegedUsers': privilegedUsers.map((user) => user.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PrivilegedUsersResponse{success: $success, message: $message, totalPrivilegedUsers: $totalPrivilegedUsers, page: $page, pageSize: $pageSize, totalPages: $totalPages, privilegedUsers: $privilegedUsers}';
  }
}