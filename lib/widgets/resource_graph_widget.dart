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
  double userTime = 0;
  double systemTime = 0;
  double idleTime = 100;

  final maxPoints = 100;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    // Listen to the stream and update data points
    subscription = statsManager.stream.listen((data) {
      setState(() {
        userTime = data.stats.userTimePercentage;
        systemTime = data.stats.systemTimePercentage;
        idleTime = data.stats.idleTimePercentage;
        _systemCPU.addLast(systemTime);
        // we want the user cpu to be stacked on top of the system
        // so we add it to system.
        _userCPU.addLast(systemTime + userTime);
        if (_userCPU.length > maxPoints) {
          _userCPU.removeFirst();
          _systemCPU.removeFirst();
        }
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
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              '       user: ${userTime.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.blue),
            ),
            Text(
              'system: ${systemTime.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.red),
            ),
            Text('           idle:  ${idleTime.toStringAsFixed(1)}'),
          ],
        ),
        SizedBox(
          height: 200,
          width: 200,
          child: LineChart(
            LineChartData(
              minX: 0, // Adjust based on your data
              maxX: maxPoints.toDouble(), // Adjust based on your data
              minY: 0, // Adjust based on your data
              maxY: 100, // Adjust based on your data

              titlesData: const FlTitlesData(
                show: false,
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
                  show: _userCPU.isNotEmpty,
                  spots: _pointsToFlSpotList(_userCPU),
                  color: Colors.blue,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: Colors.lightBlue.shade50),
                ),

                LineChartBarData(
                    show: _systemCPU.isNotEmpty,
                    spots: _pointsToFlSpotList(_systemCPU),
                    color: Colors.red,
                    dotData: const FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: Colors.red.shade50),
                    isCurved: true),

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