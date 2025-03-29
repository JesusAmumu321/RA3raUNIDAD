import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gtemp extends StatelessWidget {
  const Gtemp({super.key, required this.temp});
  final double? temp;
  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      animationDuration: 3500,
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
            minimum: -50,
            maximum: 150,
            interval: 20,
            minorTicksPerInterval: 9,
            showAxisLine: false,
            radiusFactor: 0.9,
            labelOffset: 8,
            ranges: <GaugeRange>[
              GaugeRange(
                  startValue: -50,
                  endValue: 0,
                  startWidth: 0.265,
                  sizeUnit: GaugeSizeUnit.factor,
                  endWidth: 0.265,
                  color: const Color.fromRGBO(34, 144, 199, 0.75)),
              GaugeRange(
                  startValue: 0,
                  endValue: 10,
                  startWidth: 0.265,
                  sizeUnit: GaugeSizeUnit.factor,
                  endWidth: 0.265,
                  color: const Color.fromRGBO(34, 195, 199, 0.75)),
              GaugeRange(
                  startValue: 10,
                  endValue: 30,
                  startWidth: 0.265,
                  sizeUnit: GaugeSizeUnit.factor,
                  endWidth: 0.265,
                  color: const Color.fromRGBO(123, 199, 34, 0.75)),
              GaugeRange(
                  startValue: 30,
                  endValue: 40,
                  startWidth: 0.265,
                  sizeUnit: GaugeSizeUnit.factor,
                  endWidth: 0.265,
                  color: const Color.fromRGBO(238, 193, 34, 0.75)),
              GaugeRange(
                  startValue: 40,
                  endValue: 150,
                  startWidth: 0.265,
                  sizeUnit: GaugeSizeUnit.factor,
                  endWidth: 0.265,
                  color: const Color.fromRGBO(238, 79, 34, 0.65)),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.35,
                  widget: Text('Temp.°C',
                      style:
                      TextStyle(color: Color(0xFFF8B195), fontSize: 16))),
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.8,
                widget: Text(
                  '  $temp  ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
              )
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: temp!,
                needleStartWidth: 1,
                needleEndWidth: 8,
                animationType: AnimationType.easeOutBack,
                enableAnimation: true,
                animationDuration: 1200,
                knobStyle: KnobStyle(
                    knobRadius: 0.09,
                    borderColor: const Color(0xFFF8B195),
                    color: Colors.white,
                    borderWidth: 0.05),
                tailStyle: TailStyle(
                    color: const Color(0xFFF8B195),
                    width: 8,
                    length: 0.2),
                needleColor: const Color(0xFFF8B195),
              )
            ],
            axisLabelStyle: GaugeTextStyle(fontSize: 12),
            majorTickStyle: const MajorTickStyle(
                length: 0.25, lengthUnit: GaugeSizeUnit.factor),
            minorTickStyle: const MinorTickStyle(
                length: 0.13, lengthUnit: GaugeSizeUnit.factor, thickness: 1))
      ],
    );
  }
}
