import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';

abstract class SyncRemoteDataSource {
  Future<SyncStatus> getStatus();
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  SyncRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SyncStatus> getStatus() async {
    final response = await _client.get<Map<String, dynamic>>('/sync/status');
    final data = response.data!;
    return SyncStatus(
      status: switch (data['status'] as String? ?? 'active') {
        'error' => SyncState.error,
        'revoked' => SyncState.revoked,
        _ => SyncState.active,
      },
      lastSyncAt: data['last_sync_at'] == null
          ? null
          : DateTime.parse(data['last_sync_at'] as String),
      lastError: data['last_error'] as String?,
    );
  }
}
