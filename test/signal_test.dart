import 'package:flutter/rendering.dart';
import 'package:signals/signals_flutter.dart';
import 'package:test/test.dart';

main() async {
  test('signal example', () {
    final name = signal('Jane');
    final surname = signal('Doe');
    final fullName = computed(() => '${name.value} ${surname.value}');

    effect(() => debugPrint(fullName.value));

    name.value = 'John';
  });
}
