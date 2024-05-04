import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_state.dart';
import 'package:obsydia_copy_1/pages/issue/unused_widget/unused_jention_field.dart';
import 'package:obsydia_copy_1/pages/tenant/widgets/tenant_card.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:provider/provider.dart';

class TenantPage extends StatelessWidget {
  const TenantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<TenantState>(
                stream: context.read<TenantBloc>().controller.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const LinearProgressIndicator();
                  }
                  if (snapshot.data?.tenants == null) {
                    return Container();
                  }

                  List<Tenant> listOfTenants = snapshot.data!.tenants!;
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: listOfTenants.length,
                      itemBuilder: (context, index) {
                        Tenant tenant = listOfTenants[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 15),
                          child: MultiProvider(
                            providers: [
                              Provider<Tenant>.value(value: tenant),
                            ],
                            child: const TenantCard(),
                          ),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
