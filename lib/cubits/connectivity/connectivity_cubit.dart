import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/services/connectivity_service.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._service) : super(true) {
    _init();
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _sub;

  Future<void> _init() async {
    final isOnline = await _service.isConnected;
    emit(isOnline);
    _sub = _service.stream.listen(emit);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
