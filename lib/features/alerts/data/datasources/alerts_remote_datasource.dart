import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/alerts/data/models/plan_alert_model.dart';

abstract class AlertsRemoteDataSource {
  Future<List<PlanAlertModel>> getUnreadAlerts();
  Future<void> markAsRead(String id);
}

class AlertsRemoteDataSourceImpl implements AlertsRemoteDataSource {
  AlertsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<PlanAlertModel>> getUnreadAlerts() async {
    final response = await _client.get<List<dynamic>>('/alerts');
    return (response.data ?? const [])
        .map((item) => PlanAlertModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client.post<void>('/alerts/$id/read');
  }
}
