import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_bloc.dart';
import 'package:obsydia_copy_1/bloc/auth/auth_state.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:obsydia_copy_1/pages/issue/issue_page.dart';
import 'package:obsydia_copy_1/pages/login_page.dart';
import 'package:obsydia_copy_1/pages/station_page.dart';
import 'package:obsydia_copy_1/pages/tenant/tenant_page.dart';
import 'package:obsydia_copy_1/providers/page_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
        stream: context.read<AuthBloc>().controller.stream,
        builder: (context, authSnapshot) {
          if (!authSnapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return StreamBuilder(
              stream: context.read<TenantBloc>().controller.stream,
              builder: (context, tenantSnapshot) {
                if (!tenantSnapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                Tenant? tenant = tenantSnapshot.data!.selectedTenant;
                List<Map<String, dynamic>> listOfPage = [
                  {"label": "Tenants", "page": const TenantPage()},
                  {"label": "Issue", "page": IssuePage(tenant: tenant)},
                  {
                    "label": "Station",
                    "page": StationPage(tenantId: tenant?.id),
                  },
                ];
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (context) => PageProvider(currentPage: 0))
                  ],
                  child: Builder(builder: (context) {
                    int currentPage = context.watch<PageProvider>().currentPage;
                    return Scaffold(
                      appBar: AppBar(
                        title: Text("${listOfPage[currentPage]["label"]} List"),
                        centerTitle: true,
                        scrolledUnderElevation: 0,
                        actions: [
                          IconButton(
                              onPressed: () => handleLogout(context),
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                              ))
                        ],
                      ),
                      body: listOfPage[currentPage]["page"],
                      bottomNavigationBar: BottomNavigationBar(
                        currentIndex: currentPage,
                        items: [
                          BottomNavigationBarItem(
                              icon: const Icon(Icons.home),
                              label: tenant?.id ?? "Tenants"),
                          const BottomNavigationBarItem(
                              icon: Icon(Icons.task), label: "Issues"),
                          const BottomNavigationBarItem(
                              icon: Icon(Icons.table_chart_rounded),
                              label: "Station")
                        ],
                        onTap: (value) {
                          if (value == 1 || value == 2) {
                            if (tenant == null) {
                              showSnackBarComponent(
                                  context, "Please select a tenant");
                              return;
                            }
                          }
                          context.read<PageProvider>().changePage(value);
                        },
                      ),
                    );
                  }),
                );
              });
        });
  }

  void handleLogout(BuildContext context) async {
    await context.read<AuthBloc>().logout();
    if (context.mounted) {
      showSnackBarComponent(context, "You've succesfully logout");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false);
    }
  }
}
