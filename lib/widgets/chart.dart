import 'package:polar_connect/widgets/custom_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  final List<SensorValue> _data;
  final bool markersVisible;

  Chart(this._data, {this.markersVisible = false});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        isVisible: false,
      ),
      primaryYAxis: NumericAxis(
        isVisible: false,
      ),
      series: <CartesianSeries<SensorValue, DateTime>>[
        LineSeries<SensorValue, DateTime>(
            dataSource: _data,
            xValueMapper: (SensorValue values, _) => values.time,
            yValueMapper: (SensorValue values, _) => values.value,
            width: 3,
            animationDuration: 0,
            markerSettings: MarkerSettings(
              isVisible: markersVisible,
            ))
      ],
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      palette: [CustomColors.tertiary],
      borderWidth: 0,
      plotAreaBorderWidth: 0,
    );
  }
}

class SensorValue {
  SensorValue(this.time, this.value);
  final DateTime? time;
  final double? value;
}
