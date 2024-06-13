import 'package:linux_proc/linux_proc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

const statsQueueSize = 100;
const initialRefresh = 5;

@riverpod
int refreshTime(RefreshTimeRef ref) => initialRefresh;

final statsManager =
    StatsManager(refreshTimeSeconds: initialRefresh, queueSize: statsQueueSize);

@riverpod
StatsManager stats(StatsRef ref) {
  final refresh = ref.watch(refreshTimeProvider);
  statsManager.setRefreshSeconds(refresh);
  return statsManager;
}

@riverpod
Stream<Stats> statsStream(StatsStreamRef ref) {
  return statsManager.stream;
}



// @riverpod 

// final statsManager = StatsManager(
//     refreshTimeSeconds: refreshTime.value, queueSize: statsQueueSize);
// // A stream of Linux process and system Stats
// final statsStreamSignal = statsManager.stream.toSignal();
// final procListsignal = listSignal(<Process>[]);

// final currentStats = Signal<Stats>(statsManager.currentStats);

// final c = connect(currentStats);

// void initSignals() {
//   c.from(statsManager.stream);

//   effect(() {
//     print(
//         ' Version: ${currentStats.version} ql=${statsManager.statsQueue.length}');
//   });
// }
