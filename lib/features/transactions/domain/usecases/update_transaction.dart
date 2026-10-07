import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

/// F3.3 — corrección de categoría, comercio o monto.
class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionsRepository _repository;

  Future<Either<Failure, Transaction>> call(Transaction tx) =>
      _repository.updateTransaction(tx);
}
