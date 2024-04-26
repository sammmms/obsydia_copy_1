import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/activity_model.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/utils/date_to_word_util.dart';
import 'package:obsydia_copy_1/utils/mention_formatter.dart';
import 'package:provider/provider.dart';

class IssueActivityComment extends StatefulWidget {
  final Activity activity;
  const IssueActivityComment({super.key, required this.activity});

  @override
  State<IssueActivityComment> createState() => _IssueActivityCommentState();
}

class _IssueActivityCommentState extends State<IssueActivityComment> {
  Subject? currentCommentOwner;
  @override
  void initState() {
    try {
      if (widget.activity.user != null) {
        List<Subject> listOfRelated = context.read<Issue>().relatedSubject;
        currentCommentOwner = listOfRelated
            .firstWhere((member) => member.id == widget.activity.user);
      }
    } catch (err) {
      debugPrint(err.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: const Color.fromARGB(204, 197, 214, 223),
        surfaceTintColor: Colors.transparent,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    currentCommentOwner?.displayName ??
                        currentCommentOwner?.name ??
                        "",
                    style: const TextStyle(
                        color: Color.fromARGB(242, 21, 86, 139))),
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(
                        children: MentionFormatter()
                            .mentionFormatter(widget.activity.text))),
                // Text(activity.text,
                //     style:
                //         const TextStyle(color: Color.fromARGB(178, 21, 86, 139))),
                Text(dateToWord(widget.activity.createdAt)),
              ],
            )),
      ),
    );
  }
}
