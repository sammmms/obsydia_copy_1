class User {
  final String id;
  final String name;
  final String? uniqueId;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? displayName;
  final List<dynamic> roles;

  User(
      {required this.id,
      required this.name,
      this.uniqueId,
      required this.active,
      required this.createdAt,
      required this.updatedAt,
      this.displayName,
      required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['_id'],
        name: json['name'],
        uniqueId: json['unique_id'],
        active: json['active'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        displayName: json['display_name'],
        roles: json['roles']);
  }
}
