import 'package:linux_proc/linux_proc.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals/signals.dart';

const statsQueueSize = 100;

final statsManager =
    StatsManager(refreshTimeSeconds: 4, queueSize: statsQueueSize);
// A stream of Linux process and system Stats
final statsStreamSignal = statsManager.stream.toSignal();
final procListsignal = listSignal(<Process>[]);

final currentStats = Signal<Stats>(statsManager.currentStats);

final c = connect(currentStats);

void initSignls() {
  c.from(statsManager.stream);

  effect(() {
    print(
        ' Version: ${currentStats.version} ql=${statsManager.statsQueue.length}');
  });
}
