import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/core/demo/demo_goals_repository.dart';
import 'package:fylax_front/core/demo/demo_repositories.dart';
import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fylax_front/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:fylax_front/features/categories/data/datasources/categories_remote_datasource.dart';
import 'package:fylax_front/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:fylax_front/features/categories/domain/repositories/categories_repository.dart';
import 'package:fylax_front/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:fylax_front/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fylax_front/features/goals/data/datasources/goals_remote_datasource.dart';
import 'package:fylax_front/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:fylax_front/features/goals/domain/repositories/goals_repository.dart';
import 'package:fylax_front/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:fylax_front/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:fylax_front/features/sync/domain/repositories/sync_repository.dart';
import 'package:fylax_front/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:fylax_front/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:get_it/get_it.dart';

/// Contenedor de inyección de dependencias (PRD §5.1 — get_it).
///
/// Aquí se registran los clientes HTTP, datasources, repositorios y
/// casos de uso de cada feature, de modo que la UI y los providers
/// nunca construyan dependencias a mano y los tests puedan inyectar mocks.
///
/// Dos modos (automático según AppConstants.isBackendConfigured):
/// - Backend real: SUPABASE_ANON_KEY presente → datasources remotos
///   contra el FastAPI + OAuth de Google vía Supabase Auth.
/// - Demo: sin anon-key → repositorios en memoria, app navegable.
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  if (AppConstants.isBackendConfigured) {
    _registerBackend();
  } else {
    _registerDemo();
  }
}

void _registerBackend() {
  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<TransactionsRemoteDataSource>(
    () => TransactionsRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<SyncRemoteDataSource>(
    () => SyncRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<GoalsRemoteDataSource>(
    () => GoalsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repositorios
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>()),
  );
  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(sl<TransactionsRemoteDataSource>()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(sl<SyncRemoteDataSource>()),
  );
  sl.registerLazySingleton<GoalsRepository>(
    () => GoalsRepositoryImpl(sl<GoalsRemoteDataSource>()),
  );
}

void _registerDemo() {
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
