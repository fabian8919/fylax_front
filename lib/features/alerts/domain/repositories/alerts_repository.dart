import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/alerts/domain/entities/plan_alert.dart';

abstract class AlertsRepository {
  Future<Either<Failure, List<PlanAlert>>> getUnreadAlerts();
  Future<Either<Failure, Unit>> markAsRead(String id);
}
