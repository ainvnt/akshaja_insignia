import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasNetwork(results);
  }

  Stream<bool> get onStatusChanged {
    return _connectivity.onConnectivityChanged
        .map(_hasNetwork)
        .distinct();
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
