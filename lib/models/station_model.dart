import 'package:obsydia_copy_1/models/subject_model.dart';

class Station {
  final String id;
  final String name;
  final String displayName;
  final String tenant;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic>? nfcId;
  final bool active;
  final bool requiredNfc;
  final List<dynamic> obsSubject;

  Station(
      {required this.id,
      required this.name,
      required this.displayName,
      required this.tenant,
      required this.createdAt,
      required this.updatedAt,
      required this.nfcId,
      required this.active,
      required this.requiredNfc,
      required this.obsSubject});

  factory Station.fromJson(Map<String, dynamic> json) {
    List obsSubjects = json['obs_subjects'] ?? [];
    List<Subject> listOfObsSubject =
        obsSubjects.map((e) => Subject.fromJson(e)).toList();
    return Station(
      id: json['_id'],
      active: json['active'],
      createdAt: DateTime.parse(json['createdAt']),
      displayName: json['display_name'],
      name: json['name'],
      obsSubject: listOfObsSubject,
      updatedAt: DateTime.parse(json['updatedAt']),
      requiredNfc: json['required_nfc'] ?? false,
      tenant: json['tenant'],
      nfcId: json['nfc_id'] ?? [],
    );
  }
}
