import 'package:dio/dio.dart';
import 'package:fylax_front/core/constants/app_constants.dart';

/// Cliente HTTP base (Dio) hacia el backend FastAPI.
///
/// - Base URL por entorno (PRD §12 Fase 1).
/// - Bearer token: JWT emitido por Supabase Auth, verificado por el backend
///   en cada petición (PRD §9 y §10).
/// - Las respuestas se mapean a DTOs en los datasources; los DTOs nunca
///   llegan a la UI (PRD §5.1).
class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
          ),
        )..interceptors.add(
            // TODO(Fase 5): interceptor que adjunte el JWT vigente de
            // Supabase y renueve la sesión en 401 (AuthFailure).
            LogInterceptor(requestBody: false, responseBody: false),
          );

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> patch<T>(String path, {dynamic data}) =>
      _dio.patch<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
