import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/utils/activity_priority_util.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final Tenant tenant;
  const IssueCard({super.key, required this.issue, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 250,
                  child: Text(
                    issue.title.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    if (issue.status == "closed")
                      Chip(
                        backgroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        side:
                            BorderSide(color: Colors.green.shade300, width: 2),
                        label: Text(
                          "Selesai",
                          style: TextStyle(
                              color: Colors.green.shade300,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(
                      width: 15,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.comment),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(issue.totalComments.toString())
                      ],
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(issue.reporter.name)
                  ],
                ),
                if (issue.assignee != null)
                  const SizedBox(
                    width: 30,
                  ),
                if (issue.assignee != null)
                  Row(
                    children: [
                      const Icon(Icons.paste),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(issue.assignee!.name)
                    ],
                  ),
                if (issue.collaborator?.isNotEmpty ?? false)
                  const SizedBox(
                    width: 30,
                  ),
                if (issue.collaborator?.isNotEmpty ?? false)
                  Row(
                    children: [
                      const Icon(Icons.people),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(issue.collaborator!.length.toString())
                    ],
                  ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.pin_drop_rounded),
                    const SizedBox(
                      width: 5,
                    ),
                    issue.station?.name.isNotEmpty ?? false
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.23,
                            child: Text(
                              issue.station!.name,
                              overflow: TextOverflow.ellipsis,
                            ))
                        : const Text("-"),
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Row(
                  children: [
                    const Icon(Icons.adobe),
                    const SizedBox(
                      width: 5,
                    ),
                    issue.obsSubject?.name.isNotEmpty ?? false
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.23,
                            child: Text(
                              issue.obsSubject!.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const Text("-"),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    priorityChipDecision(
                        ActivityPriorityUtil().statusNumberOf(issue.priority)),
                    const SizedBox(
                      width: 15,
                    ),
                    Chip(
                      backgroundColor: const Color.fromARGB(92, 156, 157, 167),
                      side: const BorderSide(color: Colors.transparent),
                      avatar: issue.type == "public"
                          ? const Icon(Icons.lock_outline_rounded,
                              color: Color.fromARGB(255, 45, 51, 87))
                          : const Icon(Icons.lock_open_rounded,
                              color: Color.fromARGB(255, 45, 51, 87)),
                      label: Text(issue.type),
                    )
                  ],
                ),
                Text(issue.timeSinceNow)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget priorityChipDecision(int priority) {
    if (priority == 1) {
      return const Chip(
        label: Text(
          "Very Low",
          style: TextStyle(color: Colors.white),
        ),
        color: MaterialStatePropertyAll(Color.fromARGB(158, 68, 137, 255)),
      );
    }
    if (priority == 2) {
      return const Chip(
        label: Text(
          "Low",
          style: TextStyle(color: Colors.white),
        ),
        color: MaterialStatePropertyAll(Colors.blue),
      );
    }
    if (priority == 3) {
      return const Chip(
        label: Text(
          "Medium",
          style: TextStyle(color: Colors.white),
        ),
        color: MaterialStatePropertyAll(Colors.green),
      );
    }
    if (priority == 4) {
      return const Chip(
        label: Text(
          "High",
          style: TextStyle(color: Colors.white),
        ),
        color: MaterialStatePropertyAll(Colors.redAccent),
      );
    }
    return const Chip(
      label: Text(
        "Very High",
        style: TextStyle(color: Colors.white),
      ),
      color: MaterialStatePropertyAll(Colors.red),
    );
  }
}
