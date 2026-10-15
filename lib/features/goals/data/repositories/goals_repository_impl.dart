import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/goals/data/datasources/goals_remote_datasource.dart';
import 'package:fylax_front/features/goals/data/models/goal_model.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';
import 'package:fylax_front/features/goals/domain/repositories/goals_repository.dart';

/// Implementación real de propósitos contra el backend (GET/POST /goals).
class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl(this._remote);

  final GoalsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    try {
      final models = await _remote.getGoals();
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) =>
      _mutate(() => _remote.createGoal(GoalModel.fromEntity(goal)));

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) =>
      _mutate(() => _remote.updateGoal(GoalModel.fromEntity(goal)));

  @override
  Future<Either<Failure, Goal>> addContribution(String id, double amount) =>
      _mutate(() => _remote.addContribution(id, amount));

  @override
  Future<Either<Failure, Unit>> deleteGoal(String id) async {
    try {
      await _remote.deleteGoal(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Future<Either<Failure, Goal>> _mutate(
    Future<GoalModel> Function() op,
  ) async {
    try {
      final model = await op();
      return Right(model.toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('Revisa los datos del propósito'));
      }
      return Left(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();
    if (status == 401) return const AuthFailure();
    return ServerFailure('Error $status');
  }
}
