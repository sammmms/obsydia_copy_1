import 'dart:convert';

class Tenant {
  final List roles;
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List permission;

  Tenant(
      {required this.roles,
      required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      required this.permission});

  factory Tenant.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> jsonTenant = json['tenant'];
    List<dynamic> roles;
    List<dynamic> permission;
    if (json['roles'].runtimeType == List<dynamic>) {
      roles = json['roles'];
    } else {
      roles = jsonDecode(json['roles']);
    }
    if (json['permissions'].runtimeType == List<dynamic>) {
      permission = json['permissions'];
    } else {
      permission = jsonDecode(json['permissions']);
    }
    return Tenant(
        roles: roles,
        id: jsonTenant['_id'],
        name: jsonTenant['name'],
        createdAt: DateTime.parse(jsonTenant['createdAt']),
        updatedAt: DateTime.parse(jsonTenant['updatedAt']),
        permission: permission);
  }

  Map<String, dynamic> toJson() {
    return {
      "roles": jsonEncode(roles),
      "tenant": {
        "_id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      },
      "permissions": jsonEncode(permission)
    };
  }
}
