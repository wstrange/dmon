// Widget to show process status - like top

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:linux_proc/linux_proc.dart';
import 'package:signals/signals_flutter.dart';

var procs = futureSignal(() => Process.getAllProcesses());

class ProcessWidget extends StatelessWidget {
  const ProcessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              const Text('process status'),
              IconButton(
                  onPressed: () {
                    procs.refresh();
                  },
                  icon: const Icon(Icons.refresh))
            ],
          ),
          Watch((context) => switch (procs.value) {
                AsyncData data => ProcessTable(data.requireValue),
                AsyncError error => Text('error: ${error.error}'),
                _ => const Text('loading..'),
              }),
        ],
      ),
    );
  }
}

/// Example without a datasource
class ProcessTable extends StatelessWidget {
  final List<Process> processList;

  const ProcessTable(this.processList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
              columnSpacing: 5,
              sortColumnIndex: 1,
              horizontalMargin: 5,
              isHorizontalScrollBarVisible: true,
              isVerticalScrollBarVisible: true,
              dividerThickness: 1,
              minWidth: 600,
              dataRowHeight: 20,
              columns: const [
                DataColumn2(
                  label: Text('cmd'),
                  // size: ColumnSize.L,
                ),
                DataColumn(
                  label: Text('utime'),
                  numeric: true,
                ),
                DataColumn(label: Text('sys'), numeric: true),
              ],
              rows: processList
                  .map((process) => DataRow(cells: [
                        DataCell(Text(process.command)),
                        DataCell(Text(process.userTime.toString())),
                        DataCell(Text(process.systemTime.toString())),
                      ]))
                  .toList())),
    );
  }
}
