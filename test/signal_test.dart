import 'package:flutter/rendering.dart';
import 'package:signals/signals_flutter.dart';
import 'package:test/test.dart';
import 'package:linux_proc/linux_proc.dart';

main() async {
  test('signal example', () {
    final name = signal('Jane');
    final surname = signal('Doe');
    final fullName = computed(() => '${name.value} ${surname.value}');

    effect(() => debugPrint(fullName.value));

    name.value = 'John';
  });

  test('Signal with connect', () async {
    SignalsObserver.instance = MyLog();

    final statsManager = StatsManager(refreshTimeSeconds: 2);
    // final statsSignal = statsManager.stream.toSignal();

    final recentStats = signal<Stats?>(null);
    final c = connect(recentStats);

    c.from(statsManager.stream);

    // effect(() {
    //   var x = statsSignal.value;
    //   if (x.hasValue) {
    //     recentStats.value = x.value;
    //   }
    // });

    await Future.delayed(const Duration(seconds: 5));

    print('Recent stats = ${recentStats.value?.stats.cpu}');

    // final s = signal(0);
    // final c = connect(s);

    // final s1 = Stream.value(1);
    // final s2 = Stream.value(2);

    // var x = c.from(s1).from(s2);

    // print(s.value);

    // c.dispose();
  });
}

class MyLog extends LoggingSignalsObserver {
  @override
  log(String message) => print(message);
}
