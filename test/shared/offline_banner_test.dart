import 'dart:async';

import 'package:bookshelf/core/network/connectivity_checker.dart';
import 'package:bookshelf/core/network/connectivity_view_model.dart';
import 'package:bookshelf/shared/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeConnectivity implements ConnectivityChecker {
  _FakeConnectivity({required this.initial});

  bool initial;
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasConnection() async => initial;

  @override
  Stream<bool> get onConnectivityChanged => controller.stream;
}

Widget _wrap(ConnectivityViewModel vm) {
  return ChangeNotifierProvider<ConnectivityViewModel>.value(
    value: vm,
    child: const MaterialApp(
      home: OfflineBanner(child: Scaffold(body: Text('content'))),
    ),
  );
}

void main() {
  testWidgets('hides the banner while online', (tester) async {
    final vm = ConnectivityViewModel(checker: _FakeConnectivity(initial: true));
    await vm.start();

    await tester.pumpWidget(_wrap(vm));
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsNothing);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('shows the banner when offline', (tester) async {
    final fake = _FakeConnectivity(initial: true);
    final vm = ConnectivityViewModel(checker: fake);
    await vm.start();

    await tester.pumpWidget(_wrap(vm));
    await tester.pumpAndSettle();

    fake.controller.add(false);
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
  });
}
