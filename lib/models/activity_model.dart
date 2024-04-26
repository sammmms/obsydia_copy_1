import 'package:obsydia_copy_1/utils/activity_type_util.dart';

class Activity {
  final String id;
  final String text;
  final String issue;
  final ActivityType type;
  final String action;
  final String tenant;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? user;
  final String? attachment;

  Activity(
      {required this.id,
      required this.text,
      required this.issue,
      required this.type,
      required this.action,
      required this.tenant,
      required this.createdAt,
      required this.updatedAt,
      this.user,
      this.attachment});

  factory Activity.fromJson(json) {
    return Activity(
        id: json['_id'],
        text: json['text'] ?? "",
        issue: json['issue'] ?? "",
        action: json['action'] ?? "",
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        tenant: json['tenant'],
        type: ActivityTypeUtil().typeOf(json['type']),
        user: json['user'],
        attachment: json['attachment']);
  }
}
