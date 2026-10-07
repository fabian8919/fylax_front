/// Constantes globales de la app.
///
/// Las URLs y llaves públicas (anon-key de Supabase) se inyectan por
/// flavor/entorno (dev/staging/prod — PRD §12 Fase 1); nunca se commitean
/// secretos reales, solo placeholders vía .env.example.
abstract final class AppConstants {
  static const appName = 'Fylax';

  // TODO: definir por entorno (dart-define o --flavor).
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // OAuth de Google — scope mínimo de solo lectura (PRD §10).
  static const gmailReadonlyScope =
      'https://www.googleapis.com/auth/gmail.readonly';

  // Paginación del feed de transacciones (PRD §9 — GET /transactions).
  static const defaultPageSize = 20;

  // Formato de moneda por defecto (ISO 4217 — PRD §8).
  static const defaultCurrency = 'COP';
}
