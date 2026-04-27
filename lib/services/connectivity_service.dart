import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService() {
    _sub = Connectivity().onConnectivityChanged.listen(
      (results) => _controller.add(_check(results)),
    );
  }

  final _controller = StreamController<bool>.broadcast();
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  Stream<bool> get stream => _controller.stream;

  Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    return _check(results);
  }

  static bool _check(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  void dispose() {
    _sub.cancel();
    _controller.close();
  }
}
