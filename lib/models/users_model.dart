class Users {
  final String userId;
  final String email;
  final String userName;
  final String phone;
  final bool emailConfirmed;
  final int userType;
  final DateTime? lastLogoutTime;
  final List<String> roles;
  final String? image;

  Users({
    required this.userId,
    required this.email,
    required this.userName,
    required this.phone,
    required this.emailConfirmed,
    required this.userType,
    this.lastLogoutTime,
    this.roles = const [],
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'email': email,
      'userName': userName,
      'phoneNumber': phone,
      'emailConfirmed': emailConfirmed,
      'userType': userType,
      'lastLogoutTime': lastLogoutTime?.toIso8601String(),
      'roles': roles,
      'image': image,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      userId: map['id'] ?? '',
      email: map['email'] ?? '',
      userName: map['userName'] ?? '',
      phone: map['phoneNumber'] ?? '',
      emailConfirmed: map['emailConfirmed'] ?? false,
      userType: map['userType'] ?? 0,
      lastLogoutTime: map['lastLogoutTime'] != null 
          ? DateTime.tryParse(map['lastLogoutTime'].toString())
          : null,
      roles: map['roles'] != null 
          ? List<String>.from(map['roles'])
          : [],
      image: map['image'],
    );
  }
  String get displayName => userName;
  
String get userTypeDisplay {
  switch (userType) {
    case 0:
      return 'Admin';
    case 3:
      return 'Privileged User';
    case 2:
      return 'Rider';
    case 1:
      return 'User';
    default:
      return 'User';
  }
}
}

extension UserListExtension on List<Users> {
  List<Map<String, dynamic>> toMapList() {
    return map((user) => user.toMap()).toList();
  }
}