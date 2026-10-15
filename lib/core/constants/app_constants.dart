/// Constantes globales de la app.
///
/// Las URLs y llaves públicas (anon-key de Supabase) se inyectan por
/// entorno con --dart-define (dev/staging/prod — PRD §12 Fase 1).
/// La anon-key de Supabase es pública por diseño (la seguridad real la
/// dan RLS + JWT); los secretos jamás viven en el cliente.
abstract final class AppConstants {
  static const appName = 'Fylax';

  // Base URL del backend FastAPI. Por defecto: emulador Android → el
  // host (10.0.2.2 es el alias del localhost de tu PC desde el emulador).
  // Para dispositivo físico: --dart-define=API_BASE_URL=http://<ip-pc>:8000/api/v1
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  // Proyecto Supabase (dev). La anon-key se pasa por --dart-define:
  // --dart-define=SUPABASE_ANON_KEY=eyJ...
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qskentkrweagvpljqmmn.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
