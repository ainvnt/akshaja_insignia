import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    if (!_hasNetwork(results)) {
      return false;
    }
    return _hasInternetAccess();
  }

  Stream<bool> get onStatusChanged {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (!_hasNetwork(results)) {
        return false;
      }
      return _hasInternetAccess();
    }).distinct();
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('amazonaws.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
