import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../src/sysd.dart';

final svc = futureSignal(() => sysdSvc.getUnits());

class ServiceListWidget extends StatelessWidget {
  const ServiceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(children: [
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  print('refresh');
                  svc.reload();
                },
                child: const Text('Refresh')),
            ElevatedButton(
                onPressed: () {
                  print('remove');
                },
                child: const Text('Clear')),
          ],
        ),
        switch (svc.value) {
          AsyncData data => _SvcList(data.requireValue as List<Service>),
          AsyncError error => Text('error: ${error.error}'),
          _ => const Text('loading..'),
        },
      ]),
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
