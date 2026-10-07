import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del repositorio de auth (PRD §5.1 — patrón Repository).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final model = await _remote.signInWithGoogle();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, User>> syncSessionWithBackend() async {
    try {
      final model = await _remote.syncSessionWithBackend();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(unit);
    } catch (_) {
      return const Left(AuthFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    // TODO(Fase 2): leer la sesión persistida de Supabase y mapear a User.
    return const Right(null);
  }

  @override
  Future<bool> hasGmailReadonlyScope() async {
    // TODO(Fase 2): verificar el scope del provider_token devuelto por
    // Supabase Auth (PRD §F1.2).
    return false;
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) return const AuthFailure();
    if (status == null) return const NetworkFailure();
    return ServerFailure('Error $status');
  }
}
