import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'signals.dart';

class ResourceGraphWidget extends StatefulWidget {
  const ResourceGraphWidget({super.key});

  @override
  State<ResourceGraphWidget> createState() => _ResourceGraphWidgetState();
}

class _ResourceGraphWidgetState extends State<ResourceGraphWidget> {
  final _userCPU = Queue<double>();
  final _systemCPU = Queue<double>();

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
        var s = data.stats.systemTimePercentage;
        print('u= $u s = $s');
        _systemCPU.addLast(s);
        // we want the user cpu to be stacked on top of the system
        // so we add it to system.
        _userCPU.addLast(s + u);
        if (_userCPU.length > maxPoints) {
          _userCPU.removeFirst();
          _systemCPU.removeFirst();
        }
        // _dataPoints.add(FlSpot(currentPoint.toDouble(), u));
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

  List<FlSpot> _pointsToFlSpotList(Queue<double> q) {
    int i = 0;
    return q.map((item) => FlSpot((i++).toDouble(), item)).toList();
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
                show: true,
                // bottomTitles: AxisTitles(Text('CPU')),
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
                  show: _systemCPU.isNotEmpty,
                  spots: _pointsToFlSpotList(_systemCPU),
                  color: Colors.pink,
                ),
                LineChartBarData(
                  show: _userCPU.isNotEmpty,
                  spots: _pointsToFlSpotList(_userCPU),
                  color: Colors.green,
                )

                // LineChartBarData(
                //   show: _dataPoints.isNotEmpty,
                //   spots: _dataPoints,
                //   isCurved: false, // Change to true for curved lines
                //   barWidth: 2,
                //   color: Colors.blue, // Customize color
                //   dotData: const FlDotData(show: false), // Customize dots
                //   belowBarData: BarAreaData(
                //     show: true,
                //     color: Colors.lightBlue,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
