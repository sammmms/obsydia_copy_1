import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/issue_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/component/issue_drop_down_menu.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_detail/component/issue_text_field.dart';
import 'package:obsydia_copy_1/utils/activity_priority_util.dart';
import 'package:obsydia_copy_1/utils/date_to_word_util.dart';

class IssueDetailWidget extends StatefulWidget {
  final Issue issue;
  final Tenant tenant;
  const IssueDetailWidget({
    super.key,
    required this.issue,
    required this.tenant,
  });

  @override
  State<IssueDetailWidget> createState() => _IssueDetailWidgetState();
}

class _IssueDetailWidgetState extends State<IssueDetailWidget> {
  late Issue issue;
  late Tenant tenant;
  late List<Subject> collaborator;

  @override
  void initState() {
    issue = widget.issue;
    tenant = widget.tenant;

    collaborator = widget.issue.collaborator ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dilaporkan pada ${dateToWord(issue.createdAt)}",
              style: const TextStyle(
                  color: Color.fromARGB(255, 21, 86, 139),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              issue.title,
              style: const TextStyle(
                  color: Color.fromARGB(255, 21, 86, 139),
                  fontWeight: FontWeight.bold),
              textScaler: const TextScaler.linear(1.4),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              issue.description,
              style: const TextStyle(
                  color: Color.fromARGB(255, 21, 86, 139),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pelapor"),
                    SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextField(
                        controller:
                            TextEditingController(text: issue.reporter.name),
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(131, 124, 160, 179))),
                          enabled: false,
                          contentPadding: const EdgeInsets.only(left: 10),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ditugaskan kepada"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: IssueTextField(
                          icons: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Text(
                                issue.assignee?.displayName?[0].toUpperCase() ??
                                    "-",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          text: issue.assignee?.displayName ?? "-"),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Text("Kolaborator"),
            SizedBox(
              width: 300,
              height: 50,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collaborator.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (builder, index) {
                    return Card(
                      elevation: 3,
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(collaborator[index].name),
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Stasiun"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: IssueTextField(
                          icons: const Icon(
                            Icons.place,
                            color: Colors.blueGrey,
                          ),
                          text: issue.station?.displayName ?? ""),
                    )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Subjek Observasi"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: IssueTextField(
                          icons: const Icon(
                            Icons.yard,
                            color: Colors.blueGrey,
                          ),
                          text: issue.obsSubject?.displayName ?? "-"),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  children: [
                    const Text("Tipe"),
                    IssueDropDownMenu(
                        items: const ["Public", "Private"],
                        itemSelected: issue.type)
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    const Text("Tipe"),
                    IssueDropDownMenu(
                        items: const [
                          "Very Low",
                          "Low",
                          "Medium",
                          "High",
                          "Very High"
                        ],
                        itemSelected:
                            ActivityPriorityUtil().statusTextOf(issue.priority))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
