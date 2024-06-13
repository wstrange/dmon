import 'package:flutter/material.dart';
import 'package:linux_proc/linux_proc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'service_list_widget.g.dart';

@riverpod
Future<List<Service>> services(ServicesRef ref) {
  return sysdSvc.getUnits();
}

class ServiceListWidget extends ConsumerWidget {
  ServiceListWidget({super.key});

  final filterController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.watch(servicesProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: switch (svc) {
        AsyncData(:final value) => Column(children: [
            Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: filterController,
                    maxLength: 15,
                  ),
                ),
                const Icon(Icons.filter_list),
                const SizedBox(width: 50),
                ElevatedButton(
                    onPressed: () {
                      //ref.read(servicesProvider).
                    },
                    child: const Icon(Icons.refresh)),
              ],
            ),
            _SvcList(value),
          ]),
        AsyncError() => const Text('error !!'),
        _ => const Text('loading..'),
      },
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

class _SvcWidget extends ConsumerWidget {
  final Service service;

  const _SvcWidget({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      // ref.refresh(statsProvider);
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
