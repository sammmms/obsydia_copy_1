import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/component/issue_activity_comment.dart';
import 'package:obsydia_copy_1/utils/activity_type_util.dart';
import 'package:obsydia_copy_1/utils/date_to_word_util.dart';
import 'package:obsydia_copy_1/utils/mention_formatter.dart';
import 'package:timelines/timelines.dart';

class IssueDetailTimeline extends StatelessWidget {
  final List<Activity> activityList;
  const IssueDetailTimeline({super.key, required this.activityList});

  @override
  Widget build(BuildContext context) {
    return Timeline.tileBuilder(
        theme: TimelineThemeData(nodePosition: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        builder: TimelineTileBuilder(
          itemCount: activityList.length,
          //
          startConnectorBuilder: (context, index) => (index == 0)
              ? null
              : Container(
                  constraints: const BoxConstraints(minHeight: 20),
                  child: const SolidLineConnector(
                      color: Color.fromARGB(255, 21, 86, 139))),
          //
          indicatorBuilder: (context, index) {
            return DotIndicator(
              color: const Color.fromARGB(255, 21, 86, 139),
              size: 30,
              child: Icon(
                activityList[index].type == ActivityType.comment
                    ? Icons.person
                    : Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            );
          },
          //
          endConnectorBuilder: (context, index) =>
              (index == activityList.length - 1)
                  ? null
                  : Container(
                      constraints: const BoxConstraints(minHeight: 20),
                      child: const SolidLineConnector(
                          color: Color.fromARGB(255, 21, 86, 139))),
          //
          contentsBuilder: (context, index) {
            //
            Activity currentActivity = activityList[index];
            ActivityType currentActivityType = currentActivity.type;

            return currentActivityType == ActivityType.comment
                ? IssueActivityComment(activity: currentActivity)
                : Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                            text: TextSpan(
                                children: MentionFormatter()
                                    .mentionFormatter(currentActivity.text))),
                        Text(
                          dateToWord(currentActivity.createdAt),
                        )
                      ],
                    ),
                  );
          },
        ));
  }
}
