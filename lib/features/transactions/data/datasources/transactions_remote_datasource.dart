import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/transactions/data/models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  });

  Future<TransactionModel> createTransaction(TransactionModel tx);
  Future<TransactionModel> updateTransaction(TransactionModel tx);
  Future<void> deleteTransaction(String id);
}

class TransactionsRemoteDataSourceImpl
    implements TransactionsRemoteDataSource {
  TransactionsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? categoryId,
    String? source,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/transactions',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (categoryId != null) 'category_id': categoryId,
        if (source != null) 'source': source,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );
    return (response.data ?? const [])
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel tx) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/transactions',
      data: tx.toJson(),
    );
    return TransactionModel.fromJson(response.data!);
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel tx) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/transactions/${tx.id}',
      data: tx.toJson(),
    );
    return TransactionModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _client.delete<void>('/transactions/$id');
  }
}
