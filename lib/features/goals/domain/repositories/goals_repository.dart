import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';

/// Contrato de propósitos de ahorro.
///
/// Nota de producto: los propósitos son fase posterior al MVP en el PRD
/// (§3.2), pero se adelantan por decisión del equipo. Cuando exista el
/// endpoint, la implementación real reemplaza a la demo sin tocar la UI.
abstract class GoalsRepository {
  /// Lista los propósitos activos del usuario.
  Future<Either<Failure, List<Goal>>> getGoals();

  /// Crea un propósito nuevo (nombre, monto objetivo, ícono, deadline).
  Future<Either<Failure, Goal>> createGoal(Goal goal);

  /// Edita nombre, monto objetivo o fecha límite.
  Future<Either<Failure, Goal>> updateGoal(Goal goal);

  /// Registra un aporte al propósito (incrementa savedAmount).
  Future<Either<Failure, Goal>> addContribution(String id, double amount);

  /// Elimina un propósito.
  Future<Either<Failure, Unit>> deleteGoal(String id);
}
