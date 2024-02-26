// Widget to show process status - like top

import 'dart:async';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
class ProcessTable extends StatefulWidget {
  final List<Process> processList;

  const ProcessTable(this.processList, {super.key});

  @override
  State<ProcessTable> createState() => _ProcessTableState();
}

typedef ProcField = Comparable Function(Process p);

class _ProcessTableState extends State<ProcessTable> {
  int currentIndex = 0;
  bool ascending = true;
  Timer? timer;
  ProcField currentSortFunction = (Process p) => p.pid;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 10), (_) {
      debugPrint('tick');

      _sort(0, ascending, currentSortFunction);

      // setState(() {
      //   _sort(0, true, (Process p) => p.pid);
      // });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void _sort(int columnIndex, bool asc, ProcField fn) {
    widget.processList
        .sort((a, b) => asc ? fn(a).compareTo(fn(b)) : fn(b).compareTo(fn(a)));

    setState(() {
      currentSortFunction = fn;
      currentIndex = columnIndex;
      ascending = asc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: DataTable2(
              columnSpacing: 5,
              sortColumnIndex: currentIndex,
              sortAscending: ascending,
              horizontalMargin: 5,
              isHorizontalScrollBarVisible: true,
              isVerticalScrollBarVisible: true,
              dividerThickness: 1,
              minWidth: 1000,
              dataRowHeight: 20,
              columns: [
                DataColumn2(
                  label: const Text('pid'),
                  numeric: true,
                  fixedWidth: 50,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending, (Process p) => p.pid),
                ),
                const DataColumn2(label: Text('state'), fixedWidth: 50),
                DataColumn2(
                    label: const Text('User'),
                    fixedWidth: 80,
                    onSort: (columnIndex, ascending) => _sort(
                        columnIndex, ascending, (Process p) => p.userName)),
                DataColumn2(
                    label: const Text('utime'),
                    fixedWidth: 80,
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(
                        columnIndex, ascending, (Process p) => p.userTime)),
                DataColumn2(
                    label: const Text('sys'),
                    numeric: true,
                    fixedWidth: 80,
                    onSort: (columnIndex, ascending) => _sort(
                        columnIndex, ascending, (Process p) => p.systemTime)),
                DataColumn2(
                    label: const Text('cmd'),
                    // fixedWidth: 120,
                    onSort: (columnIndex, ascending) => _sort(
                        columnIndex, ascending, (Process p) => p.command)),
              ],
              rows: widget.processList
                  .map((process) => DataRow(cells: [
                        DataCell(Text(process.pid.toString())),
                        DataCell(Text(process.state)),
                        DataCell(Text(process.userName)),
                        DataCell(Text(process.userTime.toString())),
                        DataCell(Text(process.systemTime.toString())),
                        DataCell(Text(process.command)),
                      ]))
                  .toList())),
    );
  }
}
