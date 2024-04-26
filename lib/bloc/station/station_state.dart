import 'package:obsydia_copy_1/models/station_model.dart';

class StationState {
  final List<Station>? stationList;
  final bool loading;
  final int currentPage;
  final int totalPage;
  final String? currentId;
  final bool error;

  StationState(
      {this.stationList,
      this.loading = false,
      this.currentPage = 1,
      this.totalPage = 1,
      this.currentId,
      this.error = false});
}
