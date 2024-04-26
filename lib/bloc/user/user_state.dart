import 'package:obsydia_copy_1/models/user_model.dart';

class UserState {
  List<User>? userList;
  User? user;
  bool loading;
  bool error;
  int? errorStatus;
  String? errorMessage;

  UserState(
      {this.user,
      this.userList,
      this.loading = false,
      this.error = false,
      this.errorMessage,
      this.errorStatus});
}
