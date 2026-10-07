import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';

abstract class SyncRepository {
  /// GET /sync/status — última actualización, errores y estado del watch
  /// de Gmail (PRD §9).
  Future<Either<Failure, SyncStatus>> getStatus();

  /// Reintento manual ante error (F3.4 — acción de reintento visible).
  Future<Either<Failure, Unit>> retrySync();
}
