import 'package:obsydia_copy_1/models/issue_model.dart';

class IssueState {
  final List<Issue>? issueList;
  final String? tenantId;
  final bool loading;
  final bool error;
  final int? errorStatus;
  final String? errorMessage;
  final int totalPage;
  final int currentPage;

  // Purely for saving the state of the search
  final String? status;
  final String? stationId;
  final String? obsSubject;

  IssueState(
      {this.issueList,
      this.tenantId,
      this.status,
      this.stationId,
      this.obsSubject,
      this.loading = false,
      this.error = false,
      this.errorMessage,
      this.errorStatus,
      this.totalPage = 1,
      this.currentPage = 1});
}
