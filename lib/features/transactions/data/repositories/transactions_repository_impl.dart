import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

/// Patrón Repository (PRD §5.1): la UI jamás habla con la API directo.
///
/// TODO(Fase 5): ante fallo de red, leer/escribir en el caché Isar y
/// encolar mutaciones para sincronizar cuando vuelva la conexión.
class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._remote);

  final TransactionsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final models = await _remote.getTransactions(
        page: page,
        pageSize: pageSize,
        categoryId: categoryId,
        source: source,
        from: from,
        to: to,
      );
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on DioException catch (e) {
      if (e.response == null) return const Left(NetworkFailure());
      return Left(ServerFailure('Error ${e.response?.statusCode}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(Transaction tx) =>
      _mutate(() => _remote.createTransaction, tx);

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction tx) =>
      _mutate(() => _remote.updateTransaction, tx);

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String id) async {
    try {
      await _remote.deleteTransaction(id);
      return const Right(unit);
    } on DioException catch (e) {
      if (e.response == null) return const Left(NetworkFailure());
      return Left(ServerFailure('Error ${e.response?.statusCode}'));
    }
  }

  Future<Either<Failure, Transaction>> _mutate(
    Future<dynamic> Function() op,
    Transaction tx,
  ) async {
    try {
      final model = await op();
      return Right(model.toEntity());
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) return const Left(AuthFailure());
      if (status == 422) {
        return const Left(ValidationFailure('Revisa los datos del gasto'));
      }
      if (status == null) return const Left(NetworkFailure());
      return Left(ServerFailure('Error $status'));
    }
  }
}
