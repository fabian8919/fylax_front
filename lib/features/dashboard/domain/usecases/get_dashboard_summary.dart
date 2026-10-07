import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardSummary {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, DashboardSummary>> call() => _repository.getSummary();
}
