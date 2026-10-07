import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/categories/data/models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  CategoriesRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get<List<dynamic>>('/categories');
    return (response.data ?? const [])
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
