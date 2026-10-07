import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/sync/domain/entities/sync_status.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';

class GetSyncStatus {
  const GetSyncStatus(this._repository);

  final SyncRepository _repository;

  Future<Either<Failure, SyncStatus>> call() => _repository.getStatus();
}
