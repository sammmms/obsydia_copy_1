import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_state.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc {
  final controller = BehaviorSubject<AuthState>();
  final dio = Dio();

  Future login({
    required String name,
    required String password,
    required TenantBloc tenantBloc,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? fcm = await FirebaseMessaging.instance.getToken();
      // print(fcm);
      controller.add(AuthState(loading: true));
      var response = await dio.post(
          'https://hammerhead-app-qslei.ondigitalocean.app/auth/login',
          data: {
            "name": name,
            "password": password,
            "fcm_token": "placeholder",
            "type": "mobile",
          });
      Auth responseUser = Auth.fromJson(name: name, json: response.data);
      prefs.setString('token', responseUser.token);
      String encodedUser = jsonEncode(responseUser.toJson());
      prefs.setString('user', encodedUser);
      tenantBloc.saveTenant(response.data["tenants"]);
      controller.add(AuthState(auth: responseUser));
    } catch (err) {
      controller.add(AuthState());
      rethrow;
    }
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    controller.add(AuthState());
  }

  Future checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String? token = prefs.getString('token');
      if (token != null) {
        final decodedToken = JwtDecoder.decode(token);
        if (decodedToken['exp'] >
            DateTime.now().millisecondsSinceEpoch / 1000) {
          Map<String, dynamic> decodedUser =
              jsonDecode(prefs.getString('user')!);
          Auth user =
              Auth.fromJson(name: decodedUser['name'], json: decodedUser);
          controller.add(AuthState(auth: user));
          return;
        }
      }
    } catch (err) {
      prefs.clear();
      controller.add(AuthState());
    }
  }
}
