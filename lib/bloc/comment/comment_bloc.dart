import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/comment/comment_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';

class CommentBloc {
  final String issueId;
  final String tenantId;
  final controller = StreamController<CommentState>();
  final dio = Dio();

  CommentBloc({required this.issueId, required this.tenantId});

  Future sendComment(String text) async {
    try {
      dio.interceptors.add(TokenInterceptor());
      controller.add(CommentState(loading: true));
      var response = await dio.post(
          'https://hammerhead-app-qslei.ondigitalocean.app/tenants/$tenantId/issue/$issueId/activity',
          data: {"text": text});

      var data = Activity.fromJson(response.data);
      controller.add(CommentState(response: data));
    } on DioException catch (err) {
      controller.add(
        CommentState(
            error: true,
            errorMessage: err.response!.data['message'],
            errorStatus: err.response!.statusCode),
      );
    } catch (err) {
      controller.add(CommentState(error: true));
    }
  }

  void resetState() {
    controller.add(CommentState());
  }
}
