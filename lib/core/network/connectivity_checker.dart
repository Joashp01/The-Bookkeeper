import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over connectivity so the repository can ask "is the device
/// offline?" without depending on a concrete plugin, and tests can force either
/// answer.
abstract interface class ConnectivityChecker {
  /// A one-shot check of the current connectivity.
  Future<bool> hasConnection();

  /// Emits `true` when a transport becomes available and `false` when the
  /// device goes offline. Drives the app-wide offline indicator.
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityCheckerImpl implements ConnectivityChecker {
  ConnectivityCheckerImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_isConnected);

  bool _isConnected(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
