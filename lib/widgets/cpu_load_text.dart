import 'package:flutter/material.dart';

/// Renders a text box showing the current cpu load

class CPULoadText extends StatelessWidget {
  const CPULoadText({
    super.key,
    required this.userTime,
    required this.systemTime,
    required this.idleTime,
  });

  final double userTime;
  final double systemTime;
  final double idleTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System:'),
                Text('User:'),
                Text('Idle:'),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${systemTime.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.red),
                ),
                Text(
                  '${userTime.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.blue),
                ),
                Text('${idleTime.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
