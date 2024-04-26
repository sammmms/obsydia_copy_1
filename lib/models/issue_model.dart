import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/utils/activity_priority_util.dart';
import 'package:obsydia_copy_1/utils/date_time_converter.dart';

class Issue {
  final String id;
  final String title;
  final String description;
  final Subject reporter;
  final Subject? assignee;
  final List<Subject>? collaborator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String timeSinceNow;
  final Subject? station;
  final Subject? obsSubject;
  final List<Subject> mentionableSubject;
  final List<Subject> relatedSubject;
  final String status;
  final String type;
  final ActivityPriority priority;
  final int totalComments;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.reporter,
    required this.createdAt,
    required this.updatedAt,
    required this.timeSinceNow,
    required this.totalComments,
    required this.status,
    required this.priority,
    required this.type,
    required this.mentionableSubject,
    required this.relatedSubject,
    this.obsSubject,
    this.station,
    this.assignee,
    this.collaborator,
  });

  factory Issue.fromJson(Auth auth, Map<String, dynamic> json) {
    Set<String> setOfId = {};
    List<dynamic> collaboratorJson = json['collaborator'] ?? [];
    List<Subject> listOfCollaborator =
        collaboratorJson.map((e) => Subject.fromJson(e)).toList();
    List<Subject>? listOfAllMentionable = [];
    List<Subject>? listOfAllRelated = listOfCollaborator;
    for (Subject element in listOfCollaborator) {
      setOfId.add(element.id);
      if ((element.name != auth.name) && (element.displayName != auth.name)) {
        listOfAllMentionable.add(element);
      }
    }
    Subject? reporter;
    if (json['reporter'] != null) {
      reporter = Subject.fromJson(json['reporter']);

      if ((!setOfId.contains(reporter.id))) {
        //If unique ID doesn't contain reporter ID, then add reporter to list of related
        listOfAllRelated.add(reporter);

        if ((reporter.name !=
                auth.name) && // If reporter name doesn't match with current user name, then also add to mentionable
            (reporter.displayName != auth.name)) {
          listOfAllMentionable.add(reporter);
        }
      }
    }
    Subject? assignee;
    if (json['assignee'] != null) {
      assignee = Subject.fromJson(json['assignee']);

      if ((!setOfId.contains(assignee.id))) {
        //If unique ID doesn't contain assignee ID, then add assignee to list of related
        listOfAllRelated.add(assignee);

        if ((assignee.name !=
                auth.name) && // If assignee name doesn't match with current user name, then also add to mentionable
            (assignee.displayName != auth.name)) {
          listOfAllMentionable.add(assignee);
        }
      }
    }
    return Issue(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        reporter: reporter ?? Subject(displayName: "", name: "", id: ""),
        assignee: assignee,
        collaborator: listOfCollaborator,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        priority: ActivityPriorityUtil().numberTypeOf(json['priority'] ?? 1),
        status: json['status'],
        totalComments: json['total_comments'],
        type: json['type'] ?? "private",
        station:
            json['station'] == null ? null : Subject.fromJson(json['station']),
        obsSubject: json['obs_subject'] == null
            ? null
            : Subject.fromJson(json['obs_subject']),
        timeSinceNow: dateTimeConverter(
          DateTime.parse(json['updatedAt']),
        ),
        mentionableSubject: listOfAllMentionable,
        relatedSubject: listOfAllRelated);
  }
}
