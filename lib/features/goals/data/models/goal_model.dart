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
