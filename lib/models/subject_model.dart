class Subject {
  final String id;
  final String name;
  final String? displayName;

  Subject({required this.id, required this.name, required this.displayName});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'],
      name: json['name'],
      displayName: json['display_name'],
    );
  }
}
