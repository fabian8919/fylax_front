import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      final model = await _remote.getSummary();
      return Right(model.toEntity());
    } on DioException catch (e) {
      // TODO(Fase 5): si no hay red, servir el último summary cacheado
      // en Isar (modo offline — PRD §5.1).
      if (e.response == null) return const Left(NetworkFailure());
      return Left(ServerFailure('Error ${e.response?.statusCode}'));
    }
  }
}
