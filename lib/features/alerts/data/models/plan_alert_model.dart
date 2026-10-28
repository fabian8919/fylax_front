import 'package:fylax_front/features/alerts/domain/entities/plan_alert.dart';

class PlanAlertModel {
  const PlanAlertModel({
    required this.id,
    required this.goalId,
    required this.goalName,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory PlanAlertModel.fromJson(Map<String, dynamic> json) => PlanAlertModel(
        id: json['id'] as String,
        goalId: json['goal_id'] as String,
        goalName: json['goal_name'] as String? ?? 'Tu propósito',
        kind: json['kind'] as String? ?? 'plan_at_risk',
        title: json['title'] as String? ?? 'Revisa tu plan',
        message: json['message'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String goalId;
  final String goalName;
  final String kind;
  final String title;
  final String message;
  final DateTime createdAt;

  PlanAlert toEntity() => PlanAlert(
        id: id,
        goalId: goalId,
        goalName: goalName,
        kind: kind,
        title: title,
        message: message,
        createdAt: createdAt,
      );
}
