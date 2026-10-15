import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/categories/data/datasources/categories_remote_datasource.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final models = await _remote.getCategories();
      return Right(models.map((m) => m.toEntity()).toList(growable: false));
    } on DioException catch (e) {
      // TODO(Fase 5): fallback al caché Isar (modo offline — PRD §5.1).
      if (e.response == null) return const Left(NetworkFailure());
      if (e.response?.statusCode == 401) return const Left(AuthFailure());
      return Left(ServerFailure('Error ${e.response?.statusCode}'));
    }
  }
}
