import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/station_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';

class StationProvider extends ChangeNotifier {
  Station? currentStation;
  Subject? currentObservationObject;

  StationProvider({this.currentStation});

  void changeStationSelection(Station newStation) {
    currentStation = newStation;
    notifyListeners();
  }

  void removeStationSelection() {
    currentStation = null;
    notifyListeners();
  }

  void changeObservationObject(Subject newObservationObject) {
    currentObservationObject = newObservationObject;
    notifyListeners();
  }

  void removeObservationObject() {
    currentObservationObject = null;
    notifyListeners();
  }
}
