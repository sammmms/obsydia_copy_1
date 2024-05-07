import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/issue/issue_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IssueBloc {
  final Tenant? tenant;
  final Auth? auth;

  IssueBloc({this.tenant, this.auth});

  final controller = BehaviorSubject<IssueState>();
  final dio = Dio();

  Future getIssueData({
    int currentPage = 1,
    String? status,
    String? stationId,
    String? obsSubjectId,
  }) async {
    try {
      if (tenant == null) {
        throw "Tenant shouldn't be empty.";
      }
      if (auth == null) {
        throw "You should be logged in first.";
      }
      controller.add(IssueState(loading: true));
      dio.interceptors.add(TokenInterceptor());
      String link =
          'https://hammerhead-app-qslei.ondigitalocean.app/tenants/${tenant!.id}/issue?page_no=$currentPage';
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
          data.map((e) => Issue.fromJson(auth!, e)).toList();
      controller.add(IssueState(
          issueList: listOfIssue,
          tenantId: tenant!.id,
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

  Future getIssueById(final issueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tenantsEncoded = prefs.getString('tenantList');
      if (tenantsEncoded == null) {
        throw "You must be logged in to do this.";
      }
      final decodedTenantsList = jsonDecode(tenantsEncoded);
      List<dynamic> listOfTenant = decodedTenantsList
              ?.map((tenantJson) => Tenant.fromJson(jsonDecode(tenantJson)))
              .toList() ??
          [];
      final encodedUser = prefs.getString('user');
      if (encodedUser == null) {
        throw "You must be logged in to do this.";
      }
      final decodedUser = jsonDecode(encodedUser);
      final auth = Auth.fromJson(name: decodedUser["name"], json: decodedUser);

      Issue? issue;
      dio.interceptors.add(TokenInterceptor());
      for (var tenant in listOfTenant) {
        var link =
            'https://hammerhead-app-qslei.ondigitalocean.app/tenants/${tenant.id}/issue/$issueId';
        await dio.get(link).then((response) {
          var data = response.data;
          issue = Issue.fromJson(auth, data);
        }).catchError((err) {
          print(err);
        });
        if (issue != null) {
          return {"issue": issue, "tenant": tenant};
        }
      }
      throw "Issue not found.";
      // Issue receivedResponse =
    } on DioException catch (err) {
      print(err);
      controller.add(IssueState(
          error: true,
          errorStatus: err.response?.statusCode,
          errorMessage: err.response?.data['message']));
    } catch (err) {
      print(err);
      controller.add(IssueState(error: true));
    }
  }
}
