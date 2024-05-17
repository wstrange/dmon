import 'package:dmon/widgets/resource_graph_widget.dart';
import 'package:dmon/widgets/signals.dart';
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

  initSignals();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 800),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void onWindowMinimize() {
    // set refresh to 0 to pause stats refresh
    statsManager.setRefreshSeconds(0);
  }

  @override
  void onWindowRestore() {
    statsManager.setRefreshSeconds(refreshTime.value);
  }

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
