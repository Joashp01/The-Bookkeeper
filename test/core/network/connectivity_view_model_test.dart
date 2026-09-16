import 'dart:async';

import 'package:bookshelf/core/network/connectivity_checker.dart';
import 'package:bookshelf/core/network/connectivity_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake connectivity source driven manually by the test.
class _FakeConnectivity implements ConnectivityChecker {
  _FakeConnectivity({required this.initial});

  bool initial;
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasConnection() async => initial;

  @override
  Stream<bool> get onConnectivityChanged => controller.stream;
}

void main() {
  test('seeds isOffline from the initial connectivity check', () async {
    final fake = _FakeConnectivity(initial: false);
    final vm = ConnectivityViewModel(checker: fake);

    await vm.start();

    expect(vm.isOffline, isTrue);
  });

  test('stays online when the initial check reports a connection', () async {
    final fake = _FakeConnectivity(initial: true);
    final vm = ConnectivityViewModel(checker: fake);

    await vm.start();

    expect(vm.isOffline, isFalse);
  });

  test('reacts to connectivity changes and notifies listeners', () async {
    final fake = _FakeConnectivity(initial: true);
    final vm = ConnectivityViewModel(checker: fake);
    var notifications = 0;
    vm.addListener(() => notifications++);

    await vm.start();
    expect(vm.isOffline, isFalse);

    fake.controller.add(false); // went offline
    await Future<void>.delayed(Duration.zero);
    expect(vm.isOffline, isTrue);
    expect(notifications, 1);

    fake.controller.add(true); // back online
    await Future<void>.delayed(Duration.zero);
    expect(vm.isOffline, isFalse);
    expect(notifications, 2);
  });

  test('ignores repeated identical statuses (no redundant notifications)',
      () async {
    final fake = _FakeConnectivity(initial: true);
    final vm = ConnectivityViewModel(checker: fake);
    var notifications = 0;
    vm.addListener(() => notifications++);

    await vm.start();
    fake.controller.add(true); // already online
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 0);
  });
}
