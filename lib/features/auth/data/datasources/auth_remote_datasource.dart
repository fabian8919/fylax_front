import 'dart:async';

import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/core/network/api_client.dart';
import 'package:fylax_front/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fuente remota de autenticación.
///
/// 1. OAuth de Google mediante Supabase Auth (supabase_flutter) con el
///    scope gmail.readonly solicitado explícitamente (PRD §F1.2).
///    Se pide access_type=offline para que Google entregue el
///    provider_refresh_token que el backend almacena cifrado (F1.3).
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

  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  Future<UserModel> signInWithGoogle() async {
    // Lanza el navegador con el consent screen de Google (scope
    // gmail.readonly). La sesión llega por deep link → onAuthStateChange.
    final signedIn = _auth.onAuthStateChange
        .firstWhere((state) => state.event == AuthChangeEvent.signedIn)
        .timeout(const Duration(minutes: 3));

    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.oauthRedirectTo,
      authScreenLaunchMode: LaunchMode.externalApplication,
      scopes: AppConstants.gmailReadonlyScope,
      queryParams: const {
        // Sin access_type=offline Google NO entrega refresh token.
        'access_type': 'offline',
        'prompt': 'consent',
      },
    );

    await signedIn;
    return syncSessionWithBackend();
  }

  @override
  Future<UserModel> syncSessionWithBackend() async {
    // El providerRefreshToken (refresh_token de Google) viaja UNA vez por
    // HTTPS y el backend lo almacena cifrado con AES-256-GCM (PRD §F1.3).
    final googleRefreshToken = _auth.currentSession?.providerRefreshToken;
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/session',
      data: {
        if (googleRefreshToken != null)
          'google_refresh_token': googleRefreshToken,
      },
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// Constante re-exportada para fácil acceso desde tests.
const gmailReadonlyScope = AppConstants.gmailReadonlyScope;
