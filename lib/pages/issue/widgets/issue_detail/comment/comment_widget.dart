import 'dart:async';
import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_bloc.dart';
import 'package:obsydia_copy_1/bloc/activity/activity_state.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/comment/comment_bloc.dart';
import 'package:obsydia_copy_1/bloc/comment/comment_state.dart';
import 'package:obsydia_copy_1/bloc/user/user_bloc.dart';
import 'package:obsydia_copy_1/bloc/user/user_state.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/models/user_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/comment/jention_controller.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/comment/mention_text_field.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/comment/widget/send_button.dart';
import 'package:obsydia_copy_1/providers/mention_provider.dart';
import 'package:provider/provider.dart';

class CommentWidget extends StatefulWidget {
  final String issueId;
  final String tenantId;
  const CommentWidget(
      {super.key, required this.issueId, required this.tenantId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late JentionEditingController controller;
  late MentionProvider mentionProvider;
  late CommentBloc commentBloc;
  late UserBloc userBloc;
  Timer? _mentionTimerToFire;
  late List<Map<String, dynamic>> privateSubject;

  @override
  void initState() {
    controller = JentionEditingController(onMentionStateChanged: handleSearch);
    commentBloc =
        CommentBloc(issueId: widget.issueId, tenantId: widget.tenantId);
    commentBloc.resetState();

    userBloc = UserBloc(tenantId: widget.tenantId);
    List<Subject> mentionableSubject = context.read<Issue>().mentionableSubject;
    privateSubject = mentionableSubject.map((eachSubject) {
      return {
        "id": eachSubject.id,
        "name": eachSubject.displayName ?? eachSubject.name,
        "username": eachSubject.name
      };
    }).toList();
    mentionProvider = MentionProvider(mentionable: privateSubject);

    if (context.read<Issue>().type == "public") {
      userBloc.getAllUser(
          auth: context.read<AuthBloc>().controller.value.auth!, name: "a");
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CommentState>(
        stream: commentBloc.controller.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.data?.error ?? false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarComponent(
                  context, snapshot.data?.errorMessage ?? "Terjadi kesalahan.");
            });
          }
          // Tambah comment ke activity list
          if (snapshot.data!.response != null) {
            List<Activity> currentActivityData =
                context.read<ActivityBloc>().controller.value.activityList ??
                    [];
            currentActivityData.add(snapshot.data!.response!);
            context
                .read<ActivityBloc>()
                .controller
                .add(ActivityState(activityList: currentActivityData));
            commentBloc.resetState();
          }
          CommentState state = snapshot.data!;
          // Comment section
          return ChangeNotifierProvider<MentionProvider>.value(
            value: mentionProvider,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder<UserState>(
                    stream: userBloc.controller.stream,
                    builder: (context, userSnapshot) {
                      if (userSnapshot.hasData &&
                          (userSnapshot.data?.loading ?? false)) {
                        context.read<MentionProvider>().onLoadingMentionable();
                      }
                      if (userSnapshot.hasData &&
                          !(userSnapshot.data!.loading)) {
                        handleReturnedData(userSnapshot, context);
                      }
                      return MentionTextField(
                        controller: controller,
                        onSearchFunction: handleSearch,
                        suffix: SendButton(
                          handleSentComment: () => handleSentComment(context),
                          state: state,
                        ),
                      );
                    }),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }

  void handleSearch(value) {
    // Only run fetch when issue is indeed public
    if (context.read<Issue>().type == "public") {
      if (_mentionTimerToFire?.isActive ?? false) {
        _mentionTimerToFire?.cancel();
      }
      userBloc.resetController();
      _mentionTimerToFire = Timer(
        const Duration(milliseconds: 600),
        () => userBloc.getAllUser(
            auth: context.read<AuthBloc>().controller.value.auth!, name: value),
      );
      return;
    }
    userBloc.resetController();
  }

  // To simplify the widget tree, this function is created to handle data returned after the function above
  // ran, and search fetch for new user data
  void handleReturnedData(
    AsyncSnapshot<UserState> userSnapshot,
    BuildContext context,
  ) {
    // If issue is public, then fetched data could be use as display
    if (context.read<Issue>().type == "public") {
      if (userSnapshot.data!.userList?.isNotEmpty ?? false) {
        List<User> userList = userSnapshot.data!.userList!;
        context.read<MentionProvider>().updateMentionable(userList
            .map((eachUser) => {
                  "id": eachUser.id,
                  "name": eachUser.displayName ?? eachUser.name,
                  "username": eachUser.name
                })
            .toList());
      } else {
        context.read<MentionProvider>().updateMentionable([]);
      }
    } else {
      context.read<MentionProvider>().updateMentionable(privateSubject);
    }
  }

  // Handle when send comment button is pressed
  void handleSentComment(BuildContext context) async {
    String currentText = controller.text;
    if (currentText == "") {
      showSnackBarComponent(context, "Text field shouldn't be empty");
      return;
    }
    // Send comment by using the markup text given from the controller
    await commentBloc.sendComment(controller.getMarkupText());
    // Reset the field to nothing
    controller.resetField();
  }
}
