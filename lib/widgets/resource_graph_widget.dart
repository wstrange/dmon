import 'dart:async';
import 'package:dmon/widgets/cpu_load_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class ResourceGraphWidget extends ConsumerStatefulWidget {
  const ResourceGraphWidget({super.key});

  @override
  ConsumerState<ResourceGraphWidget> createState() =>
      _ResourceGraphWidgetState();
}

class _ResourceGraphWidgetState extends ConsumerState<ResourceGraphWidget> {
  double userTime = 0;
  double systemTime = 0;
  double idleTime = 100;

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
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  // Return a list of FlSpots to display. The X coordinate is
  // the integer 0..100  where each increment is one sample. The
  // Y is the systemCPU percentage
  List<FlSpot> sysCPU() {
    int i = 0;
    return statsManager.statsQueue
        .map((s) => FlSpot((i++).toDouble(), s.stats.systemTimePercentage))
        .toList(growable: false);
  }

  // User CPU should stack on top of system - so we add it to the system time
  List<FlSpot> userCPU() {
    int i = 0;
    return statsManager.statsQueue
        .map((s) => FlSpot((i++).toDouble(),
            s.stats.systemTimePercentage + s.stats.userTimePercentage))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: 100,
      width: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(statsManager.currentStats.memInfo.memAvailable.toString()),
          CPULoadText(
              userTime: userTime, systemTime: systemTime, idleTime: idleTime),
          Container(
            height: 100,
            width: 300,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10)),
            child: LineChart(
              LineChartData(
                minX: 0, // Adjust based on your data
                maxX: 100, // Adjust based on your data
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
                    show: statsManager.statsQueue.isNotEmpty,
                    spots: userCPU(),
                    color: Colors.blue,
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: Colors.lightBlue.shade50),
                  ),

                  LineChartBarData(
                      show: statsManager.statsQueue.isNotEmpty,
                      spots: sysCPU(),
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
      ),
    );
  }
}
