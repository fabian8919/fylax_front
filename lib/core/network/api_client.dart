import 'package:dio/dio.dart';
import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente HTTP base (Dio) hacia el backend FastAPI.
///
/// - Base URL por entorno (PRD §12 Fase 1).
/// - Bearer token: JWT emitido por Supabase Auth, adjuntado en cada
///   petición por [_AuthInterceptor]; el backend lo verifica contra el
///   JWKS público del proyecto (PRD §9 y §10).
/// - Ante un 401, intenta refrescar la sesión de Supabase una sola vez
///   y reintenta la petición original.
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
        ) {
    _dio.interceptors.addAll([
      _AuthInterceptor(_dio),
      LogInterceptor(requestBody: false, responseBody: false),
    ]);
  }

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

/// Adjunta el JWT vigente de Supabase y reintenta UNA vez en 401 tras
/// refrescar la sesión (F1.1 — sesión persistente).
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;

  /// Evita bucles de reintento: marca las peticiones ya reintentadas.
  static const _retriedFlag = 'fylax_auth_retried';

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null; // Supabase no inicializado (modo demo)
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _supabase?.auth.currentSession?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;
    final supabase = _supabase;

    if (!is401 || alreadyRetried || supabase == null) {
      return handler.next(err);
    }

    try {
      // Refresca el access token con el refresh token de la sesión.
      final refreshed = await supabase.auth.refreshSession();
      final newToken = refreshed.session?.accessToken;
      if (newToken == null) return handler.next(err);

      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra[_retriedFlag] = true;
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}
