import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';

/// DTO de transacción (PRD §8 — snake_case del API).
class TransactionModel {
  const TransactionModel({
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        categoryId: json['category_id'] as String,
        date: DateTime.parse(json['date'] as String),
        merchantClean: json['merchant_clean'] as String,
        source: json['source'] == 'manual'
            ? TransactionSource.manual
            : TransactionSource.gmailApi,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'COP',
        sourceRefId: json['source_ref_id'] as String?,
      );

  /// Serializa una transacción para POST/PATCH (camelCase → snake_case).
  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'merchant_clean': merchantClean,
        'source': source.name,
        if (sourceRefId != null) 'source_ref_id': sourceRefId,
      };

  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String currency;
  final DateTime date;
  final String merchantClean;
  final TransactionSource source;
  final String? sourceRefId;

  Transaction toEntity() => Transaction(
        id: id,
        userId: userId,
        categoryId: categoryId,
        amount: amount,
        currency: currency,
        date: date,
        merchantClean: merchantClean,
        source: source,
        sourceRefId: sourceRefId,
      );
}
