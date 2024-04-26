import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:rxdart/subjects.dart';

class ActivityBloc {
  final controller = BehaviorSubject<ActivityState>();
  final String issueId;
  final String tenantId;
  final dio = Dio();

  ActivityBloc({required this.issueId, required this.tenantId});

  dispose() {
    controller.close();
  }

  Future getActivityData() async {
    try {
      dio.interceptors.add(TokenInterceptor());
      controller.add(ActivityState(loading: true));
      var response = await dio.get(
          'https://hammerhead-app-qslei.ondigitalocean.app/tenants/$tenantId/issue/$issueId');
      List<dynamic> activity = response.data["activities"];
      List<Activity> listOfActivity =
          activity.map((e) => Activity.fromJson(e)).toList();
      controller.add(ActivityState(activityList: listOfActivity));
    } on DioException catch (err) {
      controller.add(ActivityState(
          error: true,
          errorMessage: err.response?.data['message'],
          errorStatus: err.response?.statusCode));
    } catch (err) {
      controller.add(ActivityState(error: true));
    }
  }
}
