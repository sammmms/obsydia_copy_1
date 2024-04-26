enum ActivityType { logs, comment, all }

class ActivityTypeUtil {
  final Map<ActivityType, String> _map = {
    ActivityType.all: "all",
    ActivityType.logs: "logs",
    ActivityType.comment: "comment"
  };

  String statusTextOf(ActivityType choice) {
    return _map[choice] ?? "logs";
  }

  ActivityType typeOf(String string) {
    Map<String, ActivityType> reversedMap =
        _map.map((key, value) => MapEntry(value, key));
    return reversedMap[string] ?? ActivityType.logs;
  }
}
