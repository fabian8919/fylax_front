import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// Implementación del repositorio de auth (PRD §5.1 — patrón Repository).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final model = await _remote.signInWithGoogle();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on TimeoutException {
      return const Left(AuthFailure('El inicio de sesión tardó demasiado'));
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
    // Sesión persistida por supabase_flutter (SharedPreferences/Keystore).
    // Se consulta /users/me para recuperar también ingreso y presupuesto.
    final session = _supabase?.auth.currentSession;
    if (session == null) return const Right(null);

    try {
      final model = await _remote.getCurrentUser();
      return Right(model.toEntity());
    } catch (_) {
      // Si el backend no está disponible, la identidad local permite entrar;
      // la configuración financiera se recargará al volver la conexión.
      final u = session.user;
      final metadata = u.userMetadata ?? const <String, dynamic>{};
      return Right(
        User(
          id: u.id,
          email: u.email ?? '',
          name: (metadata['full_name'] ?? metadata['name'] ?? '') as String,
          subscriptionTier: 'free',
          avatarUrl: metadata['avatar_url'] as String?,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateFinancialProfile({
    required double incomeAmount,
    required String incomeFrequency,
    required double monthlyBudget,
  }) async {
    try {
      final model = await _remote.updateFinancialProfile(
        incomeAmount: incomeAmount,
        incomeFrequency: incomeFrequency,
        monthlyBudget: monthlyBudget,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(_mapError(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<bool> hasGmailReadonlyScope() async {
    // Supabase no expone los scopes concedidos; el providerToken (access
    // token de Google) solo existe si el consent screen fue aceptado con
    // los scopes solicitados (gmail.readonly — PRD §F1.2).
    return _supabase?.auth.currentSession?.providerToken != null;
  }

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) return const AuthFailure();
    if (status == null) return const NetworkFailure();
    return ServerFailure('Error $status');
  }
}
