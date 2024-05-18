import 'package:linux_proc/linux_proc.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals/signals.dart';

const statsQueueSize = 100;

final refreshTime = Signal(5);

final statsManager = StatsManager(
    refreshTimeSeconds: refreshTime.value, queueSize: statsQueueSize);
// A stream of Linux process and system Stats
final statsStreamSignal = statsManager.stream.toSignal();
final procListsignal = listSignal(<Process>[]);

final currentStats = Signal<Stats>(statsManager.currentStats);

final c = connect(currentStats);

void initSignals() {
  c.from(statsManager.stream);

  effect(() {
    print(
        ' Version: ${currentStats.version} ql=${statsManager.statsQueue.length}');
  });
}
