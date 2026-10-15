import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._remote);

  final SyncRemoteDataSource _remote;

  @override
  Future<Either<Failure, SyncStatus>> getStatus() async {
    try {
      return Right(await _remote.getStatus());
    } on DioException catch (e) {
      if (e.response == null) return const Left(NetworkFailure());
      // 404 = el usuario aún no tiene estado de sync (no hizo /auth/session).
      if (e.response?.statusCode == 404) {
        return const Right(SyncStatus(status: SyncState.active));
      }
      if (e.response?.statusCode == 401) return const Left(AuthFailure());
      return Left(ServerFailure('Error ${e.response?.statusCode}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> retrySync() async {
    // El backend reintenta la ingesta solo (backoff de Celery — F2.5);
    // el "reintento" del cliente es refrescar el estado para la UI (F3.4).
    final result = await getStatus();
    return result.fold(Left.new, (_) => const Right(unit));
  }
}
