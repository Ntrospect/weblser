import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  // Stream to listen for connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((result) {
          _isOnline = result != ConnectivityResult.none;
          print(_isOnline ? '🟢 Online' : '🔴 Offline');
          return _isOnline;
        });
  }

  // Check current status
  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }
}
