import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_app/services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _service.isConnected.then((v) {
      if (_disposed) return;
      _online = v;
      notifyListeners();
    });
    _sub = _service.stream.listen((online) {
      _online = online;
      notifyListeners();
    });
  }

  final _service = ConnectivityService();
  late final StreamSubscription<bool> _sub;
  bool _online = true;
  bool _disposed = false;

  bool get isOnline => _online;

  Future<bool> check() => _service.isConnected;

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    _service.dispose();
    super.dispose();
  }
}
