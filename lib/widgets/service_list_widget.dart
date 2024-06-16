import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:linux_proc/linux_proc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'service_list_widget.g.dart';

// @riverpod
// String servicesFilter(ServicesFilterRef ref) => 'demo';

final servicesFilterProvider = StateProvider<String>((ref) => '');

@riverpod
Future<List<Service>> services(ServicesRef ref) async {
  final f = ref.watch(servicesFilterProvider);
  final ul = await sysdSvc.getUnits();

  return f.isEmpty
      ? ul
      : ul.where((s) => s.unitName.toLowerCase().startsWith(f)).toList();
}

final filterKey = GlobalKey();

class ServiceListWidget extends HookConsumerWidget {
  const ServiceListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.watch(servicesProvider);
    final filterController = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: switch (svc) {
        AsyncData(:final value) => Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: filterController,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.filter_list),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    key: filterKey,
                    // maxLength: 15,
                    autocorrect: false,
                    autofocus: true,
                    onChanged: (x) {
                      ref.read(servicesFilterProvider.notifier).state =
                          filterController.text.toLowerCase();
                    },
                  ),
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                    onPressed: () {
                      ref.invalidate(servicesProvider);
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
                    onPressed: service.isNotRunning()
                        ? () {
                            sysdSvc.startUnit(service.unitName);
                            ref.invalidate(servicesProvider);

                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text('Start Service')),
                TextButton(
                    onPressed: service.isRunning()
                        ? () {
                            sysdSvc.stopUnit(service.unitName);
                            ref.invalidate(servicesProvider);
                            Navigator.of(context).pop();
                          }
                        : null,
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
      tileColor: Colors.lightBlue[10],
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
