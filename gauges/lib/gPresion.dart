import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GPresion extends StatelessWidget {
  const GPresion({super.key, required this.pres});
  final double? pres;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SfLinearGauge(
            minimum: 0,
            maximum: 2000,
            orientation: LinearGaugeOrientation.vertical,
            showLabels: false,
            showTicks: false,
            axisTrackStyle: const LinearAxisTrackStyle(
                thickness: 15, borderColor: Colors.black, borderWidth: 1),
            markerPointers: <LinearMarkerPointer>[
              LinearWidgetPointer(
                value: 1600,
                enableAnimation: false,
                position: LinearElementPosition.inside,
                child: Container(
                  height: 75,
                  width: 5,
                  color: Colors.orange,
                ),
              ),
            ],
            barPointers: <LinearBarPointer>[
              LinearBarPointer(
                value: pres!,
                enableAnimation: false,
                position: LinearElementPosition.cross,
                thickness: 13,
                color: const Color(0xff0074E3),
              )
            ]),
        const SizedBox(
          width: 20,
        ),
        Text(
          "$pres hPa",
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}
