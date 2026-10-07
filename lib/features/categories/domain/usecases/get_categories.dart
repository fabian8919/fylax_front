import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoriesRepository _repository;

  Future<Either<Failure, List<Category>>> call() => _repository.getCategories();
}
