import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';

abstract class CategoriesRepository {
  /// GET /categories — categorías del sistema + personalizadas (PRD §9).
  Future<Either<Failure, List<Category>>> getCategories();
}
