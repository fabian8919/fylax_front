import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionsRepository _repository;

  Future<Either<Failure, List<Transaction>>> call({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  }) =>
      _repository.getTransactions(
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
        source: source,
        from: from,
        to: to,
      );
}
