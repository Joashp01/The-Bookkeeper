import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityChecker {
  Future<bool> hasConnection();

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
