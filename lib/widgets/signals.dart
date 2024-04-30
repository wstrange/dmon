import 'package:linux_proc/linux_proc.dart';
import 'package:signals/signals_flutter.dart';

final statsManager = StatsManager(refreshTimeSeconds: 4);
final statsSignal = statsManager.stream.toSignal();
final procListsignal = listSignal(<Process>[]);
