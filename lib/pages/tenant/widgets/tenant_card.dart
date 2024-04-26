import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_bloc.dart';
import 'package:obsydia_copy_1/bloc/tenant/tenant_state.dart';
import 'package:obsydia_copy_1/components/snackbar_component.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantCard extends StatelessWidget {
  const TenantCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tenant = context.read<Tenant>();
    return StreamBuilder<TenantState>(
        stream: context.read<TenantBloc>().controller.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }
          Tenant? selectedTenant = snapshot.data!.selectedTenant;
          return GestureDetector(
            onTap: () => {changeTenant(context, selectedTenant, tenant)},
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tenant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textScaler: const TextScaler.linear(1.5),
                          ),
                          Checkbox(
                              shape: const CircleBorder(),
                              side: MaterialStateBorderSide.resolveWith(
                                  (states) =>
                                      BorderSide(color: Colors.green.shade300)),
                              fillColor: const MaterialStatePropertyAll(
                                  Colors.transparent),
                              checkColor: Colors.green,
                              value: selectedTenant?.id == tenant.id,
                              onChanged: (value) =>
                                  changeTenant(context, selectedTenant, tenant))
                        ],
                      ),
                      Text(
                        tenant.id,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.5),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: tenant.roles.map((e) {
                            return Row(
                              children: [
                                Chip(
                                  backgroundColor: Colors.blueGrey.shade50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  label: Text(e),
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ]),
              ),
            ),
          );
        });
  }

  Future changeTenant(
      BuildContext context, Tenant? selectedTenant, Tenant tenant) async {
    if (selectedTenant?.id == tenant.id) return;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tenant', jsonEncode(tenant.toJson()));
    if (context.mounted) {
      try {
        context.read<TenantBloc>().changeTenant(tenant);
        showSnackBarComponent(
            context, "You're currently working on ${tenant.id} tenant");
      } catch (err) {
        showSnackBarComponent(context, err.toString());
      }
    }
  }
}
