import 'dart:convert';

RolesResponse rolesResponseFromJson(String str) => RolesResponse.fromJson(json.decode(str));
String rolesResponseToJson(RolesResponse data) => json.encode(data.toJson());
class RolesResponse {
  final bool success;
  final List<Role> roles;

  RolesResponse({
    required this.success,
    required this.roles,
  });
  factory RolesResponse.fromJson(Map<String, dynamic> json) => RolesResponse(
    success: json["success"] ?? false,
    roles: json["roles"] == null 
        ? <Role>[]
        : List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "success": success,
    "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
  };

  Role? getRoleById(String id) {
    try {
      return roles.firstWhere((role) => role.id == id);
    } catch (e) {
      return null;
    }
  }

  Role? getRoleByName(String name) {
    try {
      return roles.firstWhere((role) => 
        role.name.toLowerCase() == name.toLowerCase() ||
        role.normalizedName.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  List<Role> get adminRoles => roles.where((role) => 
    role.name.toLowerCase().contains('admin') ||
    role.name.toLowerCase().contains('privileged')
  ).toList();

  List<Role> get userRoles => roles.where((role) => 
    role.name.toLowerCase() == 'user' ||
    role.name.toLowerCase() == 'rider'
  ).toList();
}

class Role {
  final String id;
  final String name;
  final String normalizedName;
  Role({
    required this.id,
    required this.name,
    required this.normalizedName,
  });
  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"] ?? '',
    name: json["name"] ?? '',
    normalizedName: json["normalizedName"] ?? '',
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "normalizedName": normalizedName,
  };
  bool get isAdminRole => name.toLowerCase().contains('admin') ||name.toLowerCase().contains('privileged');

  bool get isUserRole => name.toLowerCase() == 'user';

  bool get isRiderRole => name.toLowerCase() == 'rider';

  String get displayName => name;

  Role copyWith({
    String? id,
    String? name,
    String? normalizedName,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Role(id: $id, name: $name, normalizedName: $normalizedName)';
}

extension RoleListExtension on List<Role> {
  List<Map<String, dynamic>> toMapList() {
    return map((role) => role.toJson()).toList();
  }

  List<String> get roleNames => map((role) => role.name).toList();
  
  List<String> get roleIds => map((role) => role.id).toList();

  bool containsRoleName(String roleName) {
    return any((role) => 
      role.name.toLowerCase() == roleName.toLowerCase() ||
      role.normalizedName.toLowerCase() == roleName.toLowerCase()
    );
  }

  bool containsRoleId(String roleId) {
    return any((role) => role.id == roleId);
  }

  List<Role> filterByName(String searchTerm) {
    final term = searchTerm.toLowerCase();
    return where((role) => 
      role.name.toLowerCase().contains(term) ||
      role.normalizedName.toLowerCase().contains(term)
    ).toList();
  }
}