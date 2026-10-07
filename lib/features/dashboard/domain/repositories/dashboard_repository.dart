import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  /// F3.1 — balance del mes, gasto por categoría y presupuesto restante.
  Future<Either<Failure, DashboardSummary>> getSummary();
}
