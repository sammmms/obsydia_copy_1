import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  final dio = Dio(
      BaseOptions(baseUrl: "https://hammerhead-app-qslei.ondigitalocean.app"));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    SharedPreferences.getInstance().then((value) {
      String? token = value.getString('token');
      if (token != null) {
        options.headers.addAll({"Authorization": "Bearer $token"});
      }
    });

    super.onRequest(options, handler);
  }
}
