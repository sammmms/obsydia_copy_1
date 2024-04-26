import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_bloc.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_state.dart';
import 'package:obsydia_copy_1/pages/issue/unused_widget/dialog_card.dart';
import 'package:obsydia_copy_1/pages/issue/unused_widget/dialog_state.dart';
import 'package:obsydia_copy_1/pages/issue/unused_widget/dialog_navigation.dart';
import 'package:obsydia_copy_1/utils/activity_type_util.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

class IssueDialogComponent extends StatefulWidget {
  final String issueId;
  final String tenantId;
  const IssueDialogComponent(
      {super.key, required this.issueId, required this.tenantId});

  @override
  State<IssueDialogComponent> createState() => _IssueDialogComponentState();
}

class _IssueDialogComponentState extends State<IssueDialogComponent> {
  final currentChoice = BehaviorSubject<ActivityType>.seeded(ActivityType.all);
  late ActivityBloc bloc;

  @override
  void initState() {
    bloc = ActivityBloc(issueId: widget.issueId, tenantId: widget.tenantId);
    bloc.getActivityData();
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<ActivityType>.value(
            updateShouldNotify: (previous, current) => true,
            initialData: ActivityType.logs,
            value: currentChoice),
        StreamProvider<ActivityState?>.value(
            updateShouldNotify: (previous, current) => true,
            catchError: (context, error) => ActivityState(error: true),
            value: bloc.controller,
            initialData: null)
      ],
      builder: (context, child) {
        ActivityState? state = context.watch<ActivityState?>();
        bool error = state?.error ?? false;
        bool loading = state?.loading ?? true;

        var data = state?.activityList ?? [];
        ActivityType selectedType = context.watch<ActivityType>();
        // filter items, based on selected activity type
        var itemsBasedOnType = selectedType != ActivityType.all
            ? data.where((item) {
                return item.type == selectedType;
              }).toList()
            : data;

        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                /// Navbar to select either activity or comments
                IssueDetailNavigation(
                  onSelected: (choice) => currentChoice.add(choice),
                ),

                const Divider(),

                if (error) const DialogStateWidget(content: Text("error")),

                if (loading)
                  const DialogStateWidget(content: CircularProgressIndicator()),
                Flexible(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: itemsBasedOnType.length,
                      itemBuilder: (context, index) {
                        return DialogCardComponent(
                            content: itemsBasedOnType[index]);
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
