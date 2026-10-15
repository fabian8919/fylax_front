import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes globales de la app.
///
/// Las URLs y llaves públicas (anon-key de Supabase) se leen del archivo
/// `.env` (cargado en main.dart con flutter_dotenv; ver .env.example).
/// La anon-key de Supabase es pública por diseño (la seguridad real la
/// dan RLS + JWT); los secretos jamás viven en el cliente.
abstract final class AppConstants {
  static const appName = 'Fylax';

  // Base URL del backend FastAPI. 10.0.2.2 = localhost de tu PC desde el
  // emulador Android; en dispositivo físico usa la IP local de tu PC.
  static String get apiBaseUrl => dotenv.maybeGet('API_BASE_URL') ?? '';

  // Proyecto Supabase definitivo (Auth + PostgreSQL — PRD §4).
  static String get supabaseUrl => dotenv.maybeGet('SUPABASE_URL') ?? '';

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  /// DSN de Sentry (Fase 6 — monitoreo, PRD §4). Vacío = deshabilitado.
  static String get sentryDsn => dotenv.maybeGet('SENTRY_DSN') ?? '';

  /// true cuando hay backend + Supabase configurados → DI registra las
  /// implementaciones reales; si no, la app corre en modo demo.
  static bool get isBackendConfigured =>
      apiBaseUrl.isNotEmpty &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;

  // OAuth de Google — scope mínimo de solo lectura (PRD §10).
  static const gmailReadonlyScope =
      'https://www.googleapis.com/auth/gmail.readonly';

  // Deep link de retorno del flujo OAuth (ver AndroidManifest).
  static const oauthRedirectTo = 'io.supabase.flutter://login-callback';

  // Paginación del feed de transacciones (PRD §9 — GET /transactions).
  static const defaultPageSize = 20;

  // Formato de moneda por defecto (ISO 4217 — PRD §8).
  static const defaultCurrency = 'COP';
}
