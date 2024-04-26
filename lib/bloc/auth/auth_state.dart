import 'package:obsydia_copy_1/models/auth_model.dart';

class AuthState {
  final Auth? auth;
  final bool loading;
  final bool error;

  AuthState({this.auth, this.loading = false, this.error = false});
}
