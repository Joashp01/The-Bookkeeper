import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over connectivity so the repository can ask "is the device
/// offline?" without depending on a concrete plugin, and tests can force either
/// answer.
abstract interface class ConnectivityChecker {
  Future<bool> hasConnection();
}

class ConnectivityCheckerImpl implements ConnectivityChecker {
  ConnectivityCheckerImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
