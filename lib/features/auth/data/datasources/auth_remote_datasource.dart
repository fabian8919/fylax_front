import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/auth/data/models/user_model.dart';

/// Fuente remota de autenticación.
///
/// 1. OAuth de Google mediante Supabase Auth (supabase_flutter) con el
///    scope gmail.readonly solicitado explícitamente (PRD §F1.2).
/// 2. POST /auth/session para que el backend registre/actualice al usuario
///    a partir del JWT (PRD §9).
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> syncSessionWithBackend();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<UserModel> signInWithGoogle() async {
    // TODO(Fase 2):
    // final res = await Supabase.instance.client.auth.signInWithOAuth(
    //   OAuthProvider.google,
    //   authScreenLaunchMode: LaunchMode.inAppBrowserView,
    //   scopes: AppConstants.gmailReadonlyScope,
    // );
    // El provider_token (refresh_token de Google) viaja al backend,
    // que lo almacena encriptado (PRD §F1.3).
    throw UnimplementedError('Fase 2 — flujo OAuth con Supabase Auth');
  }

  @override
  Future<UserModel> syncSessionWithBackend() async {
    // TODO(Fase 2): adjuntar el JWT de Supabase en el header Authorization.
    final response = await _client.post<Map<String, dynamic>>('/auth/session');
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> signOut() async {
    // TODO(Fase 2): await Supabase.instance.client.auth.signOut();
  }
}

/// Constante re-exportada para fácil acceso desde tests.
const gmailReadonlyScope = AppConstants.gmailReadonlyScope;
