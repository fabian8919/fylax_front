import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';
import 'package:fylax_front/features/sync/domain/usecases/get_sync_status.dart';

final syncRepositoryProvider = Provider<SyncRepository>(
  (ref) => throw UnimplementedError('Registrar SyncRepository en DI'),
);

final getSyncStatusProvider = Provider(
  (ref) => GetSyncStatus(ref.watch(syncRepositoryProvider)),
);

/// Polling suave del estado de sincronización: el indicador debe reflejar
/// "Sincronizando…" / "Última actualización hace X min" / error (F3.4).
///
/// TODO(Fase 5): reemplazar polling por Server-Sent Events o actualización
/// al recibir push silencioso del backend.
final syncStatusProvider = FutureProvider<SyncStatus>((ref) async {
  final result = await ref.read(getSyncStatusProvider).call();
  return result.fold(
    (failure) => throw failure,
    (status) => status,
  );
});
