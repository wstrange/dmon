import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:linux_proc/linux_proc.dart';

final svc = futureSignal(() => sysdSvc.getUnits());

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Watch(
        (context) => Column(children: [
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    debugPrint('refresh');
                    svc.reload();
                  },
                  child: const Icon(Icons.refresh)),
              // ElevatedButton(
              //     onPressed: () {
              //       print('remove');
              //     },
              //     child: const Text('Clear')),
            ],
          ),
          switch (svc.value) {
            AsyncData data => _SvcList(data.requireValue as List<Service>),
            AsyncError error => Text('error: ${error.error}'),
            _ => const Text('loading..'),
          },
        ]),
      ),
    );
  }
}

class _SvcList extends StatelessWidget {
  final List<Service> svcList;

  const _SvcList(this.svcList);

  @override
  Widget build(BuildContext context) {
    final scroller = ScrollController();

    var c = svcList.map((i) => Text(i.name)).toList();

    return Flexible(
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8.0,
            controller: scroller,
            child: ListView(controller: scroller, children: c)));
  }
}

