import 'dart:async';

import 'package:flutter/foundation.dart';

import 'connectivity_checker.dart';

/// Presentation-layer holder for the device's online/offline status.
///
/// Seeds itself with the current connectivity, then follows the
/// [ConnectivityChecker] stream so the app-wide offline indicator reflects
/// changes live. Depends only on the abstraction, so tests can drive it with a
/// fake stream.
class ConnectivityViewModel extends ChangeNotifier {
  // Named parameters cannot be private, so assigning in the initializer list is
  // the idiomatic alternative (hence the lint suppression).
  ConnectivityViewModel({required ConnectivityChecker checker})
      : _checker = checker; // ignore: prefer_initializing_formals

  final ConnectivityChecker _checker;
  StreamSubscription<bool>? _subscription;

  // Assume online until proven otherwise so we never flash the offline banner
  // on a healthy start-up before the first check resolves.
  bool _isOnline = true;
  bool get isOffline => !_isOnline;

  /// Reads the current status once, then subscribes to future changes.
  Future<void> start() async {
    _setOnline(await _checker.hasConnection());
    _subscription = _checker.onConnectivityChanged.listen(_setOnline);
  }

  void _setOnline(bool online) {
    if (online == _isOnline) {
      return;
    }
    _isOnline = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
