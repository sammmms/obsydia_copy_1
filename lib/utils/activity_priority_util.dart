enum ActivityPriority { veryLow, low, medium, high, veryHigh }

class ActivityPriorityUtil {
  final Map<ActivityPriority, String> _stringMap = {
    ActivityPriority.veryLow: "very low",
    ActivityPriority.low: "low",
    ActivityPriority.medium: "medium",
    ActivityPriority.high: "high",
    ActivityPriority.veryHigh: "very high"
  };
  final Map<ActivityPriority, int> _intMap = {
    ActivityPriority.veryLow: 1,
    ActivityPriority.low: 2,
    ActivityPriority.medium: 3,
    ActivityPriority.high: 4,
    ActivityPriority.veryHigh: 5
  };

  String statusTextOf(ActivityPriority choice) {
    return _stringMap[choice] ?? "Very Low";
  }

  ActivityPriority typeOf(String string) {
    Map<String, ActivityPriority> reversedMap =
        _stringMap.map((key, value) => MapEntry(value, key));
    return reversedMap[string] ?? ActivityPriority.veryLow;
  }

  int statusNumberOf(ActivityPriority choice) {
    return _intMap[choice] ?? 0;
  }

  ActivityPriority numberTypeOf(int number) {
    Map<int, ActivityPriority> reversedMap =
        _intMap.map((key, value) => MapEntry(value, key));
    return reversedMap[number] ?? ActivityPriority.veryLow;
  }
}
