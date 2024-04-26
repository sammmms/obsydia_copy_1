import 'dart:async';

import 'package:dio/dio.dart';
import 'package:obsydia_copy_1/bloc/station/station_state.dart';
import 'package:obsydia_copy_1/interceptor/dio_token_interceptor.dart';
import 'package:obsydia_copy_1/models/station_model.dart';

class StationBloc {
  final String tenantId;

  StationBloc({required this.tenantId});
  final controller = StreamController<StationState>();
  final dio = Dio();
  Future getStationData({int? pageNumber = 1}) async {
    try {
      dio.interceptors.add(TokenInterceptor());
      controller.add(StationState(loading: true));
      var response = await dio.get(
          'https://hammerhead-app-qslei.ondigitalocean.app/tenants/$tenantId/stations?page_no=$pageNumber&with_obs_subjects=10');
      Map<String, dynamic> meta = response.data['meta'];
      List<dynamic> data = response.data['data'];
      List<Station> listOfStation =
          data.map((e) => Station.fromJson(e)).toList();
      controller.add(StationState(
          stationList: listOfStation,
          currentPage: meta['page_no'],
          totalPage: meta['total_page'],
          currentId: tenantId));
    } catch (err) {
      controller.add(StationState(error: true));
    }
  }
}
