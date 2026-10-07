import 'package:fylax_front/core/network/api_client.dart';
import 'package:get_it/get_it.dart';

/// Contenedor de inyección de dependencias (PRD §5.1 — get_it).
///
/// Aquí se registran los clientes HTTP, datasources, repositorios y
/// casos de uso de cada feature, de modo que la UI y los providers
/// nunca construyan dependencias a mano y los tests puedan inyectar mocks.
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  // TODO(Fase 5): registrar por feature, por ejemplo:
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(sl()),
  // );
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(sl()),
  // );
  // sl.registerLazySingleton(() => SignInWithGoogle(sl()));
}
