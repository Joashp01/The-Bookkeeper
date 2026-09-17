import 'package:bookshelf/core/network/connectivity_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late ConnectivityChecker checker;

  setUp(() {
    connectivity = _MockConnectivity();
    checker = ConnectivityCheckerImpl(connectivity: connectivity);
  });

  test('reports connected when a transport is available', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);

    expect(await checker.hasConnection(), isTrue);
  });

  test('reports disconnected when the only result is none', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.none]);

    expect(await checker.hasConnection(), isFalse);
  });
}
