import 'package:equatable/equatable.dart';

/// Entidad de dominio de una transacción (PRD §8 — tabla transactions).
///
/// - amount: Decimal(10,2) en BD; aquí double con formateo cuidadoso
///   (ver Formatters). ISO 4217 para currency (ej. COP).
/// - source: manual | gmail_api. Las de gmail_api llevan sourceRefId
///   (ID del correo) — la clave de la idempotencia UNIQUE
///   (user_id, source_ref_id) del backend (PRD §F2.6).
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.merchantClean,
    required this.source,
    this.sourceRefId,
  });

  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String currency;
  final DateTime date;

  /// Comercio limpio (ya normalizado por el parser/JEV).
  final String merchantClean;

  final TransactionSource source;
  final String? sourceRefId;

  bool get isManual => source == TransactionSource.manual;

  @override
  List<Object?> get props => [
        id, userId, categoryId, amount, currency, date,
        merchantClean, source, sourceRefId,
      ];
}

enum TransactionSource { manual, gmailApi }
