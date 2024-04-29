import 'package:flutter/material.dart';
import 'package:obsydia_copy_1/models/station_model.dart';
import 'package:obsydia_copy_1/models/subject_model.dart';
import 'package:obsydia_copy_1/providers/station_provider.dart';
import 'package:provider/provider.dart';

class StationCardComponent extends StatelessWidget {
  final Station station;
  const StationCardComponent({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Text(
                      station.displayName,
                      textScaler: const TextScaler.linear(1.6),
                    ),
                  ),
                  Checkbox(
                      side: MaterialStateBorderSide.resolveWith((states) =>
                          BorderSide(color: Colors.blue.shade100, width: 2)),
                      shape: const CircleBorder(),
                      checkColor: Colors.blue.shade300,
                      fillColor:
                          const MaterialStatePropertyAll(Colors.transparent),
                      value: context.watch<StationProvider>().currentStation ==
                          station,
                      onChanged: (value) {
                        if (context.read<StationProvider>().currentStation ==
                            station) {
                          //RUN IF STATION ALREADY SELECTED
                          context
                              .read<StationProvider>()
                              .removeStationSelection();
                        } else {
                          // IF STATION NOT SELECTED, THEN CHANGE STATION TO THIS
                          context
                              .read<StationProvider>()
                              .changeStationSelection(station);
                        }
                        context
                            .read<StationProvider>()
                            .removeObservationObject();
                      })
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (station.obsSubject.isNotEmpty)
                const Text("Observable Subjects : "),
              if (station.obsSubject.isNotEmpty)
                SizedBox(
                  height: 40,
                  width: 400,
                  child: ListView.builder(
                      itemCount: station.obsSubject.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Subject currentSubject = station.obsSubject[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ChoiceChip(
                            selectedColor: Colors.blueAccent,
                            selected: context
                                    .watch<StationProvider>()
                                    .currentObservationObject ==
                                currentSubject,
                            onSelected: (value) {
                              if (context
                                      .read<StationProvider>()
                                      .currentObservationObject ==
                                  currentSubject) {
                                context
                                    .read<StationProvider>()
                                    .removeObservationObject();
                              } else {
                                context
                                    .read<StationProvider>()
                                    .changeObservationObject(currentSubject);
                              }
                              context
                                  .read<StationProvider>()
                                  .changeStationSelection(station);
                            },
                            backgroundColor: Colors.blue.shade50,
                            label: Text(currentSubject.name),
                          ),
                        );
                      }),
                )
            ],
          ),
        ),
      ),
    );
  }
}
