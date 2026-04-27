import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/cubits/alerts/alerts_state.dart';
import 'package:mobile_app/data/repositories/alert_repository.dart';

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(this._repo) : super(AlertsLoading()) {
    loadAlerts();
  }

  final AlertRepository _repo;

  Future<void> loadAlerts() async {
    emit(AlertsLoading());
    try {
      final alerts = await _repo.getAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
}
