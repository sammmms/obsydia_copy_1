import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/issue/issue_bloc.dart';
import 'package:obsydia_copy_1/bloc/issue/issue_state.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/models/station_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/issue_detail_page.dart';
import 'package:obsydia_copy_1/pages/issue/widgets/issue_card.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:obsydia_copy_1/utils/page_logic.dart';
import 'package:provider/provider.dart';

class IssuePage extends StatefulWidget {
  final Tenant? tenant;
  final Station? station;
  final Subject? obsSubject;
  const IssuePage(
      {super.key, required this.tenant, this.station, this.obsSubject});

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  late IssueBloc bloc;

  @override
  void initState() {
    try {
      bloc = IssueBloc(
          auth: context.read<AuthBloc>().controller.value.auth!,
          tenant: widget.tenant!);
      bloc.getIssueData(
          stationId: widget.station?.id, obsSubjectId: widget.obsSubject?.id);
    } catch (err) {
      debugPrint(err.toString());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.station == null
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 220,
                    ),
                    child: Text("${widget.station!.displayName.toString()}'s"),
                  ),
                  Text(" Issue List")
                ],
              ),
              centerTitle: true,
            ),
      body: StreamBuilder<IssueState>(
          stream: bloc.controller.stream,
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data!.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.error ?? false) {
              IssueState error = snapshot.data!;
              print(error.errorStatus.toString());
              if (error.errorStatus == 400) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showSnackBarComponent(
                      context, error.errorMessage ?? "Terjadi kesalahan.");
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showSnackBarComponent(
                      context, "Token expired, please login.");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                });
              }
            }
            var data = snapshot.data!;
            var issueList = data.issueList ?? [];
            Map<String, int> page = pageLogic(data);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: ListTile(
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        leading: const Text(
                          "Filter",
                          textScaler: TextScaler.linear(1.6),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green.shade300),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                            borderRadius: BorderRadius.circular(20),
                            dropdownColor: Colors.green.shade300,
                            items: const [
                              DropdownMenuItem(value: null, child: Text("All")),
                              DropdownMenuItem(
                                  value: "open", child: Text("Open")),
                              DropdownMenuItem(
                                  value: "closed", child: Text("Closed")),
                            ],
                            value: data.status,
                            onChanged: (value) => bloc.getIssueData(
                                currentPage: 1,
                                status: value,
                                stationId: data.stationId,
                                obsSubjectId: data.obsSubject),
                          )),
                        ),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: issueList.length,
                        itemBuilder: (context, index) {
                          var issue = issueList[index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => IssueDetailPage(
                                        issue: issue, tenant: widget.tenant!))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10),
                              child: IssueCard(
                                issue: issue,
                                tenant: widget.tenant!,
                              ),
                            ),
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // BACK BUTTON (GO TO FIRST PAGE)
                        GestureDetector(
                          onTap: data.currentPage == 1
                              ? null
                              : () => bloc.getIssueData(
                                  currentPage: 1,
                                  status: data.status,
                                  stationId: data.stationId,
                                  obsSubjectId: data.obsSubject),
                          child: const Icon(Icons.keyboard_double_arrow_left),
                        ),
                        //PAGE BUTTON ( MAX 7 NUMBER )
                        for (int i = page['lowest']!;
                            i <= page['highest']!;
                            i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: GestureDetector(
                              onTap: () => bloc.getIssueData(
                                  currentPage: i,
                                  status: data.status,
                                  stationId: data.stationId,
                                  obsSubjectId: data.obsSubject),
                              child: Text(
                                i.toString(),
                                style: TextStyle(
                                    color: data.currentPage == i
                                        ? Colors.blue
                                        : Colors.grey),
                                textScaler: data.currentPage == i
                                    ? const TextScaler.linear(1.5)
                                    : const TextScaler.linear(1.2),
                              ),
                            ),
                          ),
                        // FORWARD BUTTON (GO TO LAST PAGE)
                        GestureDetector(
                          onTap: data.currentPage == data.totalPage
                              ? null
                              : () => bloc.getIssueData(
                                  currentPage: data.totalPage,
                                  status: data.status,
                                  stationId: data.stationId,
                                  obsSubjectId: data.obsSubject),
                          child: const Icon(Icons.keyboard_double_arrow_right),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
