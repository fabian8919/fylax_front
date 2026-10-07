import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';
import 'package:fylax_front/features/goals/domain/repositories/goals_repository.dart';

/// Repositorio demo de propósitos: datos en memoria para que la feature
/// sea usable sin backend. Se reemplaza por la implementación real cuando
/// exista el endpoint (ver injection.dart).
class DemoGoalsRepository implements GoalsRepository {
  DemoGoalsRepository();

  final List<Goal> _items = [
    Goal(
      id: 'goal-moto',
      userId: 'demo-user-001',
      name: 'Moto nueva',
      targetAmount: 8000000,
      savedAmount: 2450000,
      icon: 'moto',
      color: '#2E8FFF',
      deadline: DateTime(2027, 6, 30),
      createdAt: DateTime(2026, 8, 12),
    ),
    Goal(
      id: 'goal-viaje',
      userId: 'demo-user-001',
      name: 'Viaje a San Andrés',
      targetAmount: 3500000,
      savedAmount: 875000,
      icon: 'travel',
      color: '#00D68F',
      deadline: DateTime(2026, 12, 20),
      createdAt: DateTime(2026, 9, 1),
    ),
    Goal(
      id: 'goal-deuda',
      userId: 'demo-user-001',
      name: 'Saldar tarjeta de crédito',
      targetAmount: 2000000,
      savedAmount: 1600000,
      icon: 'debt',
      color: '#34E0A1',
      createdAt: DateTime(2026, 7, 22),
    ),
  ];

  int _seq = 100;

  @override
  Future<Either<Failure, List<Goal>>> getGoals() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return Right(List.unmodifiable(_items));
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final created = Goal(
      id: 'goal-${_seq++}',
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      savedAmount: 0,
      icon: goal.icon,
      color: goal.color,
      deadline: goal.deadline,
      createdAt: DateTime.now(),
    );
    _items.add(created);
    return Right(created);
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _items.indexWhere((g) => g.id == goal.id);
    if (index == -1) return const Left(ServerFailure('Propósito no existe'));
    _items[index] = goal;
    return Right(goal);
  }

  @override
  Future<Either<Failure, Goal>> addContribution(
    String id,
    double amount,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _items.indexWhere((g) => g.id == id);
    if (index == -1) return const Left(ServerFailure('Propósito no existe'));
    final updated = _items[index].copyWith(
      savedAmount: _items[index].savedAmount + amount,
    );
    _items[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, Unit>> deleteGoal(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((g) => g.id == id);
    return const Right(unit);
  }
}
