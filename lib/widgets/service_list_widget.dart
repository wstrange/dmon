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

    var c = svcList.map((svc) => _SvcWidget(service: svc)).toList();

    return Flexible(
        child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8.0,
            controller: scroller,
            child: ListView(controller: scroller, children: c)));
  }
}

class _SvcWidget extends StatelessWidget {
  final Service service;

  const _SvcWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    Future<void> serviceDialog(Service service) async {
      await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text(service.unitName),
              actions: [
                TextButton(
                    onPressed: () {
                      sysdSvc.startUnit(service.unitName);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Start Service')),
                TextButton(
                    onPressed: () {
                      sysdSvc.stopUnit(service.unitName);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Stop Service')),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          });
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.offline_bolt_sharp),
      title: Text(service.unitName),
      subtitle: Text(service.description),
      trailing: Text('${service.loadeState}:${service.subState}'),
      isThreeLine: false,
      tileColor: Colors.lightBlue[50],
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onTap: () => serviceDialog(service),
    );

    // InkWell(
    //   onTap: () {
    //     print('tap ${service.unitName}');
    //   },
    //   onHover: (s) {},
    //   child: ListTile(
    //     dense: true,
    //     leading: Text(service.unitName),

    //   ),

    //   // child: Row(children: [
    //   //   Flexible(
    //   //     child: Tooltip(
    //   //       message: service.description,
    //   //       preferBelow: false,
    //   //       child: Text(
    //   //         '${service.unitName}',
    //   //         softWrap: true,
    //   //       ),
    //   //     ),
    //   //   ),
    //   // ])
    // );
  }
}
