import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/alerts/data/datasources/alerts_remote_datasource.dart';
import 'package:fylax_front/features/alerts/domain/entities/plan_alert.dart';
import 'package:fylax_front/features/alerts/domain/repositories/alerts_repository.dart';

class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl(this._remote);

  final AlertsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PlanAlert>>> getUnreadAlerts() async {
    try {
      final alerts = await _remote.getUnreadAlerts();
      return Right(alerts.map((item) => item.toEntity()).toList());
    } on DioException catch (error) {
      return Left(
        error.response == null
            ? const NetworkFailure()
            : ServerFailure('Error ${error.response?.statusCode}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    try {
      await _remote.markAsRead(id);
      return const Right(unit);
    } on DioException {
      return const Left(ServerFailure());
    }
  }
}

class DemoAlertsRepository implements AlertsRepository {
  @override
  Future<Either<Failure, List<PlanAlert>>> getUnreadAlerts() async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async =>
      const Right(unit);
}
