import 'package:mobile_app/data/models/alert.dart';

sealed class AlertsState {}

final class AlertsLoading extends AlertsState {}

final class AlertsLoaded extends AlertsState {
  AlertsLoaded(this.alerts);
  final List<Alert> alerts;
}

final class AlertsError extends AlertsState {
  AlertsError(this.message);
  final String message;
}
