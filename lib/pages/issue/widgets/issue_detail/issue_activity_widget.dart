import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_bloc.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_state.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/component/issue_detail_timeline.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:provider/provider.dart';

class IssueActivityWidget extends StatefulWidget {
  final Tenant tenant;
  final Issue issue;
  const IssueActivityWidget(
      {super.key, required this.tenant, required this.issue});

  @override
  State<IssueActivityWidget> createState() => _IssueActivityWidgetState();
}

class _IssueActivityWidgetState extends State<IssueActivityWidget> {
  late ActivityBloc bloc;

  @override
  void initState() {
    bloc = context.read<ActivityBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: StreamBuilder(
        stream: bloc.controller.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.loading) {
            return const SizedBox(
                height: 500, child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data?.error ?? false) {
            ActivityState error = snapshot.data!;
            if (error.errorStatus == 400) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showSnackBarComponent(
                    context, error.errorMessage ?? "Terjadi kesalahan.");
                Navigator.of(context).pop();
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showSnackBarComponent(context, "Token expired, please login.");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              });
            }
          }
          List<Activity> activityList = snapshot.data!.activityList ?? [];
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Aktivitas",
                  style: TextStyle(color: Color.fromARGB(255, 21, 86, 139)),
                  textScaler: TextScaler.linear(1.4),
                ),
                IssueDetailTimeline(activityList: activityList),
              ],
            ),
          );
        },
      ),
    );
  }
}
