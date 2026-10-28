import 'package:equatable/equatable.dart';

/// Propósito de ahorro del usuario: la razón de fondo para cuidar su
/// salud financiera (comprar carro o moto, viajar, saldar deudas, etc.).
///
/// Da contexto emocional al ahorro y será la base de las notificaciones
/// accionables de avance de objetivos (PRD §7 — fase posterior al MVP).
class GoalActionPlan extends Equatable {
  const GoalActionPlan({
    required this.incomeFrequency,
    required this.recommendedContribution,
    required this.monthlyContribution,
    required this.feasible,
    required this.requiresIncomeSetup,
    required this.message,
    this.monthsToGoal,
    this.estimatedCompletion,
    this.status = 'on_track',
    this.monthlySpent = 0,
    this.remainingBudget = 0,
    this.alertMessage,
  });

  final String incomeFrequency;
  final double recommendedContribution;
  final double monthlyContribution;
  final int? monthsToGoal;
  final DateTime? estimatedCompletion;
  final bool feasible;
  final bool requiresIncomeSetup;
  final String message;
  final String status;
  final double monthlySpent;
  final double remainingBudget;
  final String? alertMessage;

  String get periodLabel => incomeFrequency == 'biweekly' ? 'quincena' : 'mes';
  bool get isAtRisk => status == 'at_risk';
  bool get isOffTrack => status == 'off_track';

  @override
  List<Object?> get props => [
        incomeFrequency,
        recommendedContribution,
        monthlyContribution,
        monthsToGoal,
        estimatedCompletion,
        feasible,
        requiresIncomeSetup,
        message,
        status,
        monthlySpent,
        remainingBudget,
        alertMessage,
      ];
}

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.icon,
    required this.color,
    this.deadline,
    this.createdAt,
    this.plan,
  });

  final String id;
  final String userId;
  final String name;

  /// Monto objetivo del propósito (Decimal en BD, ISO 4217).
  final double targetAmount;

  /// Total aportado hasta ahora.
  final double savedAmount;

  /// Identificador de ícono (car, moto, travel, debt, home, gadget…).
  final String icon;

  /// Color de acento en hex (ej. '#2E8FFF').
  final String color;

  /// Fecha límite opcional.
  final DateTime? deadline;

  final DateTime? createdAt;

  /// Plan calculado por el backend con ingreso, gastos y fecha límite.
  final GoalActionPlan? plan;

  /// Progreso entre 0.0 y 1.0.
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  bool get isCompleted => savedAmount >= targetAmount;

  double get remaining => (targetAmount - savedAmount).clamp(0, targetAmount);

  Goal copyWith({
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? icon,
    String? color,
    DateTime? deadline,
    GoalActionPlan? plan,
  }) =>
      Goal(
        id: id,
        userId: userId,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        deadline: deadline ?? this.deadline,
        createdAt: createdAt,
        plan: plan ?? this.plan,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        targetAmount,
        savedAmount,
        icon,
        color,
        deadline,
        createdAt,
        plan,
      ];
}
