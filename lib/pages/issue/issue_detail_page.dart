import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_bloc.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/issue_activity_widget.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/issue_detail_comment.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/issue_detail_widget.dart';
import 'package:provider/provider.dart';

class IssueDetailPage extends StatefulWidget {
  final Issue issue;
  final Tenant tenant;
  const IssueDetailPage({
    super.key,
    required this.issue,
    required this.tenant,
  });

  @override
  State<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  late Issue issue;
  late Tenant tenant;
  late List<Subject> collaborator;
  late ActivityBloc bloc;

  @override
  void initState() {
    issue = widget.issue;
    tenant = widget.tenant;
    bloc = ActivityBloc(issueId: issue.id, tenantId: tenant.id);
    bloc.getActivityData();

    collaborator = widget.issue.collaborator ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ActivityBloc>.value(value: bloc),
        Provider<Issue>.value(value: widget.issue)
      ],
      child: Builder(builder: (context) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("Detail Issue"),
              scrolledUnderElevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IssueDetailWidget(issue: issue, tenant: tenant),
                    Row(
                      children: [
                        Expanded(
                            child: IssueActivityWidget(
                                tenant: tenant, issue: issue)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: IssueDetailComment(
                          issue: widget.issue,
                          tenant: tenant,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      }),
    );
  }
}
