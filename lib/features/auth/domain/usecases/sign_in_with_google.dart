import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: F1.1 — login seguro con Google sin contraseña.
class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call() => _repository.signInWithGoogle();
}
