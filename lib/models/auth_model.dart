class Auth {
  final String name;
  final String token;

  Auth({required this.name, required this.token});

  factory Auth.fromJson({
    required String name,
    required Map<String, dynamic> json,
  }) {
    return Auth(name: name, token: json['token']);
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "token": token};
  }
}
