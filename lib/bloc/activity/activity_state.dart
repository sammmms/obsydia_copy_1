import 'package:obsydia_copy_1/models/activity_model.dart';

class ActivityState {
  final List<Activity>? activityList;
  final bool loading;
  final bool error;
  final String? errorMessage;
  final int? errorStatus;

  ActivityState(
      {this.activityList,
      this.loading = false,
      this.error = false,
      this.errorMessage,
      this.errorStatus});
}
