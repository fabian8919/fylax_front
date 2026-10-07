import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';

abstract class TransactionsRepository {
  /// GET /transactions — lista paginada con filtros por fecha, categoría
  /// y fuente (PRD §9).
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  });

  /// POST /transactions — creación manual (efectivo u otros — F3.3).
  Future<Either<Failure, Transaction>> createTransaction(Transaction tx);

  /// PATCH /transactions/{id} — edita monto, categoría o comercio (F3.3).
  Future<Either<Failure, Transaction>> updateTransaction(Transaction tx);

  /// DELETE /transactions/{id}.
  Future<Either<Failure, Unit>> deleteTransaction(String id);
}
