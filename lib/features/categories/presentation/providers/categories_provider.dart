import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => sl<CategoriesRepository>(),
);

/// Categorías del sistema + personalizadas (GET /categories).
///
/// El formulario manual y futuros filtros del feed las consumen.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await ref.read(categoriesRepositoryProvider).getCategories();
  return result.fold(
    (failure) => throw failure,
    (categories) => categories,
  );
});
