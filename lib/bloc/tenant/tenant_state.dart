import 'package:obsydia_copy_1/models/tenant_model.dart';

class TenantState {
  final Tenant? selectedTenant;
  final List<Tenant>? tenants;
  final bool loading;
  final bool error;

  TenantState(
      {this.selectedTenant,
      this.tenants,
      this.loading = false,
      this.error = false});
}
