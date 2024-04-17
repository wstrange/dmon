import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'signals.dart';

class ResourceGraphWidget extends StatefulWidget {
  const ResourceGraphWidget({super.key});

  @override
  State<ResourceGraphWidget> createState() => _ResourceGraphWidgetState();
}

class _ResourceGraphWidgetState extends State<ResourceGraphWidget> {
  List<FlSpot> _dataPoints = [];
  int maxPoints = 100;
  int currentPoint = 0;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    // Listen to the stream and update data points
    subscription = statsManager.stream.listen((data) {
      setState(() {
        var u = data.stats.userTimePercentage;
        _dataPoints.add(FlSpot(currentPoint.toDouble(), u));
        // _dataPoints = List.from(_dataPoints);
        ++currentPoint;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$currentPoint'),
        SizedBox(
          height: 400,
          width: 400,
          child: LineChart(
            LineChartData(
              minX: 0, // Adjust based on your data
              maxX: 200, // Adjust based on your data
              minY: 0, // Adjust based on your data
              maxY: 100, // Adjust based on your data

              titlesData: const FlTitlesData(
                show: false,
                // Customize titles and labels as needed
              ),
              gridData: const FlGridData(
                show: false,
                // Customize grid lines as needed
              ),
              borderData: FlBorderData(
                show: false,
                // Customize border as needed
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _dataPoints,
                  isCurved: false, // Change to true for curved lines
                  barWidth: 2,
                  color: Colors.blue, // Customize color
                  dotData: const FlDotData(show: false), // Customize dots
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.lightBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
