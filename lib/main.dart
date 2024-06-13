import 'package:dmon/widgets/resource_graph_widget.dart';
import 'package:dmon/widgets/providers.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/process_widget.dart';
import 'widgets/service_list_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

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

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
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
    var r = ref.watch(refreshTimeProvider);
    statsManager.setRefreshSeconds(r);
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
          body: TabBarView(children: [
            const ProcessWidget(),
            ServiceListWidget(),
            const ResourceGraphWidget(),
          ]),
        ),
      ),
    );
  }
}
