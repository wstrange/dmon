import 'package:dmon/widgets/resource_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'widgets/process_widget.dart';
import 'widgets/service_list_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  // To supress signals debug messages comment this out:
  SignalsObserver.instance = null;

  WindowOptions windowOptions = const WindowOptions(
    size: Size(500, 800),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ssystem Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.memory), text: 'Processes'),
                Tab(icon: Icon(Icons.settings), text: 'Systemd'),
                Tab(icon: Icon(Icons.auto_graph), text: 'Resources'),
              ],
            ),
          ),
          body: const TabBarView(children: [
            ProcessWidget(),
            ServiceListWidget(),
            ResourceGraphWidget(),
          ]),
        ),
      ),
    );
  }
}
