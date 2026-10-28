import 'package:fylax_front/core/utils/parse_amount.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';

/// DTO de propósito de ahorro (snake_case del API — POST/GET /goals).
class GoalModel {
  const GoalModel({
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

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        targetAmount: parseApiAmount(json['target_amount']),
        savedAmount: parseApiAmount(json['saved_amount']),
        icon: json['icon'] as String? ?? 'savings',
        color: json['color'] as String? ?? '#2E8FFF',
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        plan: json['plan'] == null
            ? null
            : GoalActionPlanModel.fromJson(
                json['plan'] as Map<String, dynamic>,
              ),
      );

  /// Serializa para POST /goals (el servidor asigna id, user y ahorro).
  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'target_amount': targetAmount,
        'icon': icon,
        'color': color,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
      };

  /// Serializa para PATCH /goals/{id}.
  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'target_amount': targetAmount,
        'icon': icon,
        'color': color,
        'deadline': deadline?.toIso8601String(),
      };

  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String icon;
  final String color;
  final DateTime? deadline;
  final DateTime? createdAt;
  final GoalActionPlanModel? plan;

  Goal toEntity() => Goal(
        id: id,
        userId: userId,
        name: name,
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        icon: icon,
        color: color,
        deadline: deadline,
        createdAt: createdAt,
        plan: plan?.toEntity(),
      );

  factory GoalModel.fromEntity(Goal goal) => GoalModel(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        targetAmount: goal.targetAmount,
        savedAmount: goal.savedAmount,
        icon: goal.icon,
        color: goal.color,
        deadline: goal.deadline,
        createdAt: goal.createdAt,
      );
}

class GoalActionPlanModel {
  const GoalActionPlanModel({
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

  factory GoalActionPlanModel.fromJson(Map<String, dynamic> json) =>
      GoalActionPlanModel(
        incomeFrequency: json['income_frequency'] as String? ?? 'monthly',
        recommendedContribution:
            parseApiAmount(json['recommended_contribution']),
        monthlyContribution: parseApiAmount(json['monthly_contribution']),
        monthsToGoal: json['months_to_goal'] as int?,
        estimatedCompletion: json['estimated_completion'] == null
            ? null
            : DateTime.parse(json['estimated_completion'] as String),
        feasible: json['feasible'] as bool? ?? false,
        requiresIncomeSetup: json['requires_income_setup'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'on_track',
        monthlySpent: parseApiAmount(json['monthly_spent']),
        remainingBudget: parseApiAmount(json['remaining_budget']),
        alertMessage: json['alert_message'] as String?,
      );

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

  GoalActionPlan toEntity() => GoalActionPlan(
        incomeFrequency: incomeFrequency,
        recommendedContribution: recommendedContribution,
        monthlyContribution: monthlyContribution,
        monthsToGoal: monthsToGoal,
        estimatedCompletion: estimatedCompletion,
        feasible: feasible,
        requiresIncomeSetup: requiresIncomeSetup,
        message: message,
        status: status,
        monthlySpent: monthlySpent,
        remainingBudget: remainingBudget,
        alertMessage: alertMessage,
      );
}
