import 'package:equatable/equatable.dart';

class PlanAlert extends Equatable {
  const PlanAlert({
    required this.id,
    required this.goalId,
    required this.goalName,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final String goalName;
  final String kind;
  final String title;
  final String message;
  final DateTime createdAt;

  bool get isOffTrack => kind == 'plan_off_track';

  @override
  List<Object?> get props => [id, goalId, kind, title, message, createdAt];
}
