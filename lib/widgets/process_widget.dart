// Widget to show process status - like top

import 'dart:io' as dartio;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:linux_proc/linux_proc.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class ProcessWidget extends StatelessWidget {
  const ProcessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: ProcessTable(),
    );
  }
}

/// Example without a datasource
class ProcessTable extends ConsumerStatefulWidget {
  // final List<Process> processList;

  const ProcessTable({super.key});

  @override
  ConsumerState<ProcessTable> createState() => _ProcessTableState();
}

typedef ProcField = Comparable Function(Process p);

class _ProcessTableState extends ConsumerState<ProcessTable> {
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
    statsManager.setProcessSortOrder(fn, asc);

    setState(() {
      currentSortFunction = fn;
      currentIndex = columnIndex;
      ascending = asc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsStream = ref.watch(statsStreamProvider);

    if (!statsStream.hasValue) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Reading Process Status....   '),
          CircularProgressIndicator(),
        ],
      );
    }
    var procList = statsStream.asData!.value.processes;

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
        showCheckboxColumn: false,
        columns: [
          DataColumn2(
            label: const Text('pid'),
            numeric: true,
            fixedWidth: 50,
            onSort: (columnIndex, ascending) =>
                _sort(columnIndex, ascending, (Process p) => p.procPid),
          ),
          const DataColumn2(label: Text('state'), fixedWidth: 50),
          DataColumn2(
              label: const Text('User'),
              fixedWidth: 80,
              onSort: (columnIndex, ascending) =>
                  _sort(columnIndex, ascending, (Process p) => p.userName)),
          DataColumn2(
              label: const Text('%CPU'),
              fixedWidth: 80,
              numeric: true,
              onSort: (columnIndex, ascending) => _sort(
                  columnIndex, ascending, (Process p) => p.cpuPercentage)),
          DataColumn2(
              label: const Text('utime'),
              fixedWidth: 80,
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort(columnIndex, ascending, (Process p) => p.userTime)),
          DataColumn2(
              label: const Text('sys'),
              numeric: true,
              fixedWidth: 80,
              onSort: (columnIndex, ascending) =>
                  _sort(columnIndex, ascending, (Process p) => p.systemTime)),
          DataColumn2(
              label: const Text('cmd'),
              // fixedWidth: 120,
              onSort: (columnIndex, ascending) =>
                  _sort(columnIndex, ascending, (Process p) => p.command)),
        ],
        rows: procList
            .map((process) => DataRow(
                    onSelectChanged: (value) =>
                        _showProcessDialog(context, process),
                    cells: [
                      DataCell(Text(process.procPid.toString())),
                      DataCell(Text(process.state)),
                      DataCell(Text(process.userName)),
                      DataCell(Text(process.cpuPercentage.toStringAsFixed(1))),
                      DataCell(Text(process.userTime.toString())),
                      DataCell(Text(process.systemTime.toString())),
                      DataCell(Text(process.command)),
                    ]))
            .toList());
  }

  _showProcessDialog(BuildContext context, Process p) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('${p.procPid} ${p.command}'),
            content: Text('user: ${p.userName}'),
            actions: [
              TextButton(
                  child: Text('Kill ${p.procPid}'),
                  onPressed: () {
                    // todo: How to sigkill a process!
                    dartio.Process.killPid(p.procPid);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}
