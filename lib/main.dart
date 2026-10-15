import 'package:fylax_front/app/app.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Punto de entrada de Fylax.
///
/// Antes de arrancar la UI se inicializa:
/// 1. Inyección de dependencias (get_it).
/// 2. Datos de localización (fechas en español — Formatters).
/// 3. Supabase (auth + sesión persistente) si hay anon-key configurada.
/// 4. Sentry (trazabilidad de errores desde el día uno — PRD §4).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  await initializeDateFormatting('es');

  // Con SUPABASE_ANON_KEY presente, la app corre contra el backend real;
  // sin ella, arranca en modo demo (ver injection.dart).
  if (AppConstants.supabaseUrl.isNotEmpty &&
      AppConstants.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
    );
  }

  // TODO(Fase 6): inicializar Sentry con DSN.
  // await SentryFlutter.init(...);

  runApp(const FylaxApp());
}
