import 'dart:async';

import 'package:flutter/foundation.dart';

import 'connectivity_checker.dart';

class ConnectivityViewModel extends ChangeNotifier {
  ConnectivityViewModel({required ConnectivityChecker checker})
    : _checker = checker; // ignore: prefer_initializing_formals

  final ConnectivityChecker _checker;
  StreamSubscription<bool>? _subscription;

  bool _isOnline = true;
  bool get isOffline => !_isOnline;

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
