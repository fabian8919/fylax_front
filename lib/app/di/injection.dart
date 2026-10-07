import 'package:fylax_front/core/demo/demo_goals_repository.dart';
import 'package:fylax_front/core/demo/demo_repositories.dart';
import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fylax_front/features/goals/domain/repositories/goals_repository.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';
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

  // ── Repositorios ────────────────────────────────────────────────
  // Mientras el backend FastAPI + Supabase Auth no estén configurados
  // (API_BASE_URL / SUPABASE_URL vacíos), la app corre en modo demo con
  // repositorios en memoria: la UI es navegable de punta a punta.
  //
  // TODO(Fase 5): cuando existan las variables de entorno, registrar las
  // implementaciones reales (AuthRepositoryImpl, etc.) en su lugar.
  sl.registerLazySingleton<AuthRepository>(DemoAuthRepository.new);
  sl.registerLazySingleton<CategoriesRepository>(
    DemoCategoriesRepository.new,
  );
  sl.registerLazySingleton<DemoTransactionsRepository>(
    DemoTransactionsRepository.new,
  );
  sl.registerLazySingleton<TransactionsRepository>(
    () => sl<DemoTransactionsRepository>(),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DemoDashboardRepository(sl<DemoTransactionsRepository>()),
  );
  sl.registerLazySingleton<SyncRepository>(DemoSyncRepository.new);
  sl.registerLazySingleton<GoalsRepository>(DemoGoalsRepository.new);
}
