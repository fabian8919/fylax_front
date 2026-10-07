import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/dashboard/data/models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/dashboard/summary',
    );
    return DashboardSummaryModel.fromJson(response.data!);
  }
}
