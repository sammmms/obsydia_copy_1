import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/issue/issue_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:rxdart/subjects.dart';

class IssueBloc {
  final Tenant tenant;
  final Auth auth;

  IssueBloc({required this.tenant, required this.auth});

  final controller = BehaviorSubject<IssueState>();
  final dio = Dio();

  Future getIssueData({
    int currentPage = 1,
    String? status,
    String? stationId,
    String? obsSubjectId,
  }) async {
    try {
      controller.add(IssueState(loading: true));
      dio.interceptors.add(TokenInterceptor());
      String link =
          'https://hammerhead-app-qslei.ondigitalocean.app/tenants/${tenant.id}/issue?page_no=$currentPage';
      if (status != null) {
        link += "&status=$status";
      }
      if (stationId != null) {
        link += "&station=$stationId";
      }
      if (obsSubjectId != null) {
        link += "&obs_subject=$obsSubjectId";
      }
      var response = await dio.get(link);
      List<dynamic> data = response.data['data'];
      Map<String, dynamic> meta = response.data['meta'];
      List<Issue> listOfIssue =
          data.map((e) => Issue.fromJson(auth, e)).toList();
      controller.add(IssueState(
          issueList: listOfIssue,
          tenantId: tenant.id,
          currentPage: meta['page_no']!,
          totalPage: meta['total_page']!,
          status: status,
          stationId: stationId,
          obsSubject: obsSubjectId));
    } on DioException catch (err) {
      controller.add(IssueState(
          error: true,
          errorStatus: err.response?.statusCode,
          errorMessage: err.response?.data['message']));
    } catch (err) {
      controller.add(IssueState(error: true));
    }
  }
}
