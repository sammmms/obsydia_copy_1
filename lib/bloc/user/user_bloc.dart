import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/user/user_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:obsydia_copy_1/models/user_model.dart';

class UserBloc {
  final String tenantId;
  final String? userId;
  UserBloc({required this.tenantId, this.userId});

  final controller = StreamController<UserState>();
  final dio = Dio();

  Future getUser() async {
    try {
      controller.add(UserState(loading: true));
      dio.interceptors.add(TokenInterceptor());
      var response = await dio.get(
          "https://hammerhead-app-qslei.ondigitalocean.app/tenants/$tenantId/users/$userId");
      Map<String, dynamic> data = response.data;
      User user = User.fromJson(data);
      controller.add(UserState(user: user));
    } on DioException {
      controller.add(UserState(error: true));
      rethrow;
    }
  }

  Future getAllUser({required String name, required Auth auth}) async {
    try {
      controller.add(UserState(loading: true));
      dio.interceptors.add(TokenInterceptor());
      var response = await dio.get(
          "https://hammerhead-app-qslei.ondigitalocean.app/tenants/$tenantId/users?search=$name&active=true");
      List<dynamic> data = response.data['data'];
      List<User> listOfUser = data.map((json) => User.fromJson(json)).toList();
      List<User> filteredListOfUser = listOfUser.where((element) {
        return (element.name != auth.name) &&
            (element.displayName != auth.name);
      }).toList();
      controller.add(UserState(userList: filteredListOfUser));
    } on DioException catch (err) {
      controller.add(UserState(
          error: true,
          errorMessage: err.response?.data['message'],
          errorStatus: err.response?.statusCode));
    } catch (err) {
      controller.add(UserState(error: true));
    }
  }

  void resetController() {
    controller.add(UserState());
  }
}
