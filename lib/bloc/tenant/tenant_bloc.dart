import 'dart:async';
import 'dart:convert';

import 'package:obsydia_copy_1/bloc/tenant/tenant_state.dart';
import 'package:obsydia_copy_1/models/tenant_model.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantBloc {
  final controller = BehaviorSubject<TenantState>();

  Future getTenant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Tenant? savedTenantPreferences;
      List<dynamic>? savedTenantList;
      // GET SELECTED TENANT FROM LOCAL STORAGE
      if (prefs.getString('selectedTenant') != null) {
        savedTenantPreferences =
            Tenant.fromJson(jsonDecode(prefs.getString('selectedTenant')!));
      }
      // GET TENANT LIST (ARRAY OF ENCODED JSON)
      savedTenantList = jsonDecode(prefs.getString('tenantList')!);
      // MAP THE ARRAY OF ENCODED JSON, DECODE IT AND CONVERT IT INTO OBJECT
      List<Tenant> decodedTenantList = savedTenantList
              ?.map((tenantJson) => Tenant.fromJson(jsonDecode(tenantJson)))
              .toList() ??
          [];
      if (decodedTenantList.isEmpty) {
        throw "Array kosong.";
      }
      controller.add(
        TenantState(
          tenants: decodedTenantList,
          selectedTenant: savedTenantPreferences,
        ),
      );
    } catch (err) {
      controller.add(TenantState(error: true));
      rethrow;
    }
  }

  Future saveTenant(List<dynamic> receivedTenants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Tenant> listOfTenants = receivedTenants
          .map(
            (tenantJson) => Tenant.fromJson(tenantJson),
          )
          .toList();
      controller.add(TenantState(tenants: listOfTenants));
      List listOfTenantsJson =
          listOfTenants.map((tenant) => jsonEncode(tenant.toJson())).toList();
      prefs.setString('tenantList', jsonEncode(listOfTenantsJson));
    } catch (err) {
      controller.add(TenantState(error: true));
      rethrow;
    }
  }

  Future changeTenant(Tenant tenant) async {
    List<Tenant> listOfTenant = controller.stream.value.tenants!;
    Tenant? selectedTenant = controller.stream.value.selectedTenant;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedTenant', jsonEncode(tenant.toJson()));
      controller
          .add(TenantState(tenants: listOfTenant, selectedTenant: tenant));
    } catch (err) {
      controller.add(TenantState(
          tenants: listOfTenant, selectedTenant: selectedTenant, error: true));
      rethrow;
    }
  }
}
