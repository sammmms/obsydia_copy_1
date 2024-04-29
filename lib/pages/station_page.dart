import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/station/station_bloc.dart';
import 'package:obsydia_copy_1/bloc/station/station_state.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/components/station_card_component.dart';
import 'package:obsydia_copy_1/models/station_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/issue_page.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:obsydia_copy_1/providers/station_provider.dart';
import 'package:provider/provider.dart';

class StationPage extends StatefulWidget {
  final String? tenantId;
  const StationPage({super.key, required this.tenantId});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  late StationBloc bloc;
  late Tenant tenant;
  @override
  void initState() {
    bloc = StationBloc(tenantId: widget.tenantId!);
    bloc.getStationData();
    tenant = context.read<TenantBloc>().controller.value.selectedTenant!;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => StationProvider()),
        ],
        child: StreamBuilder<StationState>(
            stream: bloc.controller.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || (snapshot.data?.loading ?? false)) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.error) {
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
              List<Station> stations = snapshot.data!.stationList ?? [];
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: stations.length,
                          itemBuilder: (context, index) {
                            return StationCardComponent(
                              station: stations[index],
                            );
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      if (snapshot.data!.stationList != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: snapshot.data!.currentPage <= 1
                                  ? null
                                  : () => handleGetStationData(context,
                                      pageToVisit:
                                          snapshot.data!.currentPage - 1),
                              child: Icon(Icons.arrow_back_ios,
                                  color: snapshot.data!.currentPage > 1
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5.5),
                              child: Chip(
                                side: const BorderSide(
                                    color: Colors.black38, width: 1),
                                shape: const CircleBorder(),
                                label:
                                    Text(snapshot.data!.currentPage.toString()),
                              ),
                            ),
                            GestureDetector(
                              onTap: snapshot.data!.currentPage >=
                                      snapshot.data!.totalPage
                                  ? null
                                  : () => handleGetStationData(context,
                                      pageToVisit:
                                          snapshot.data!.currentPage + 1),
                              child: Icon(Icons.arrow_forward_ios,
                                  color: snapshot.data!.currentPage <
                                          snapshot.data!.totalPage
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                floatingActionButton:
                    context.watch<StationProvider>().currentStation == null
                        ? null
                        : FloatingActionButton(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.blueAccent.shade100,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              Station currentStation = context
                                  .read<StationProvider>()
                                  .currentStation!;
                              Subject? currentObservationObject = context
                                  .read<StationProvider>()
                                  .currentObservationObject;
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IssuePage(
                                        tenant: tenant,
                                        station: currentStation,
                                        obsSubject: currentObservationObject,
                                      )));
                            }),
              );
            }),
      ),
    );
  }

  void handleGetStationData(BuildContext context,
      {int? pageToVisit = 1}) async {
    try {
      await bloc.getStationData(pageNumber: pageToVisit);
    } on DioException catch (err) {
      bloc.controller.add(StationState());
      if (context.mounted) {
        showSnackBarComponent(
            context,
            // err.response?.statusMessage.toString() ??
            err.response?.data.toString() ?? err.toString());
      }
    } catch (err) {
      bloc.controller.add(StationState());
      if (context.mounted) {
        showSnackBarComponent(context, err.toString());
      }
    }
  }
}
