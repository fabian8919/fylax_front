import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión local y revocar la sesión de Supabase.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.signOut();
}
