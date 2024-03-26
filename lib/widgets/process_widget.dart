// Widget to show process status - like top

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:linux_proc/linux_proc.dart';
import 'package:signals/signals_flutter.dart';

final statsManager = StatsManager(refreshTimeSeconds: 2);
final statsSignal = statsManager.stream.toSignal();
final procListsignal = listSignal(<Process>[]);

final dispose = effect(() {
  if (statsSignal.value.hasValue) {
    var p = statsSignal.requireValue.processes;
    procListsignal.value = p;
    print('updated signal');
  }
});

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
              Text('process'),
              IconButton(
                  onPressed: () {
                    ///procs.refresh();
                  },
                  icon: const Icon(Icons.refresh)),
              Watch((context) => Text('plist ${procListsignal.length}'))
            ],
          ),
          const ProcessTable(),
          // Watch((context) => switch (statsSignal.value) {
          //       AsyncData<Stats> data => ProcessTable(data.value.processes),
          //       AsyncError error => Text('error: ${error.error}'),
          //       _ => const Text('loading..'),
          //     }),
        ],
      ),
    );
  }
}

/// Example without a datasource
class ProcessTable extends StatefulWidget {
  // final List<Process> processList;

  const ProcessTable({super.key});

  @override
  State<ProcessTable> createState() => _ProcessTableState();
}

typedef ProcField = Comparable Function(Process p);

class _ProcessTableState extends State<ProcessTable> {
  int currentIndex = 0;
  bool ascending = true;
  ProcField currentSortFunction = (Process p) => p.procPid;
  var procList = <Process>[];
  late ScrollController scrollController;
  late ScrollController horizontalController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    horizontalController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sort(int columnIndex, bool asc, ProcField fn) {
    // Sort the current view
    Process.sort(procList, fn, asc);
    // set the sort order for subsequent processes
    statsManager.setSortOrder(fn, asc);

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
          child: Watch(
            (context) {
              if (statsSignal.value.hasValue) {
                procList = statsSignal.value.requireValue.processes;
              }
              return DataTable2(
                  columnSpacing: 5,
                  sortColumnIndex: currentIndex,
                  sortAscending: ascending,
                  horizontalMargin: 5,
                  isHorizontalScrollBarVisible: false,
                  isVerticalScrollBarVisible: true,
                  scrollController: scrollController,
                  horizontalScrollController: horizontalController,
                  dividerThickness: 1,
                  minWidth: 800,
                  dataRowHeight: 20,
                  columns: [
                    DataColumn2(
                      label: const Text('pid'),
                      numeric: true,
                      fixedWidth: 50,
                      onSort: (columnIndex, ascending) => _sort(
                          columnIndex, ascending, (Process p) => p.procPid),
                    ),
                    const DataColumn2(label: Text('state'), fixedWidth: 50),
                    DataColumn2(
                        label: const Text('User'),
                        fixedWidth: 80,
                        onSort: (columnIndex, ascending) => _sort(
                            columnIndex, ascending, (Process p) => p.userName)),
                    DataColumn2(
                        label: const Text('%CPU'),
                        fixedWidth: 80,
                        numeric: true,
                        onSort: (columnIndex, ascending) => _sort(columnIndex,
                            ascending, (Process p) => p.cpuPercentage)),
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
                        onSort: (columnIndex, ascending) => _sort(columnIndex,
                            ascending, (Process p) => p.systemTime)),
                    DataColumn2(
                        label: const Text('cmd'),
                        // fixedWidth: 120,
                        onSort: (columnIndex, ascending) => _sort(
                            columnIndex, ascending, (Process p) => p.command)),
                  ],
                  rows: procList
                      .map((process) => DataRow(cells: [
                            DataCell(Text(process.procPid.toString())),
                            DataCell(Text(process.state)),
                            DataCell(Text(process.userName)),
                            DataCell(
                                Text(process.cpuPercentage.toStringAsFixed(1))),
                            DataCell(Text(process.userTime.toString())),
                            DataCell(Text(process.systemTime.toString())),
                            DataCell(Text(process.command)),
                          ]))
                      .toList());
            },
          )),
    );
  }
}
