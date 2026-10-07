import 'package:equatable/equatable.dart';

/// Contrato de errores de dominio (capa Domain nunca ve excepciones
/// de infraestructura: DioException, IsarError, etc.).
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesión inválida o expirada']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}
