import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionsRepository _repository;

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteTransaction(id);
}
