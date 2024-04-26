import 'package:obsydia_copy_1/models/activity_model.dart';

class CommentState {
  final Activity? response;
  final bool loading;
  final bool error;
  final String? errorMessage;
  final int? errorStatus;

  CommentState(
      {this.loading = false,
      this.error = false,
      this.response,
      this.errorMessage,
      this.errorStatus});
}
