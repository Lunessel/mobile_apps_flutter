import 'package:mobile_app/data/models/alert.dart';

abstract interface class AlertRepository {
  Future<List<Alert>> getAlerts();
}
