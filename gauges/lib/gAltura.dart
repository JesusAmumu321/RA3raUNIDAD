import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GAltura extends StatelessWidget {
  const GAltura({super.key, required this.alt});
  final double? alt;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SfLinearGauge(
            minimum: 0,
            maximum: 4000,
            minorTicksPerInterval: 4,
            orientation: LinearGaugeOrientation.vertical,
            axisTrackStyle: const LinearAxisTrackStyle(thickness: 15),
            axisLabelStyle: const TextStyle(color: Colors.white),
            markerPointers: <LinearMarkerPointer>[
              LinearWidgetPointer(
                value: alt!,
                enableAnimation: false,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Image.asset(
                    'assets/images/triangle_pointer.png',
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            barPointers: <LinearBarPointer>[
              LinearBarPointer(
                value: alt!,
                enableAnimation: false,
                thickness: 8,
                color: const Color(0xff0074E3),
              )
            ]),
        const SizedBox(
          width: 20,
        ),
        Text(
          "$alt m",
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }
}
