import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/models/auth_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/comment_widget.dart';
import 'package:provider/provider.dart';

class IssueDetailComment extends StatefulWidget {
  final Issue issue;
  final Tenant tenant;
  const IssueDetailComment(
      {super.key, required this.issue, required this.tenant});

  @override
  State<IssueDetailComment> createState() => _IssueDetailCommentState();
}

class _IssueDetailCommentState extends State<IssueDetailComment> {
  late bool showComment = false;
  @override
  void initState() {
    Issue issue = widget.issue;
    Auth user = context.read<AuthBloc>().controller.value.auth!;
    if (issue.reporter.name == user.name) showComment = true;
    if (issue.assignee?.name == user.name) showComment = true;
    issue.collaborator?.forEach((element) {
      if ((element.name == user.name) || (element.displayName == user.name)) {
        showComment = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Komentar",
              style: TextStyle(color: Color.fromARGB(255, 21, 86, 139)),
              textScaler: TextScaler.linear(1.4),
            ),
            showComment
                ? CommentWidget(
                    issueId: widget.issue.id,
                    tenantId: widget.tenant.id,
                  )
                : const Text("You are not allowed to comment in this issue.")
          ],
        ),
      ),
    );
  }
}
