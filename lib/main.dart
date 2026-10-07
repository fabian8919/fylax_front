import 'package:fylax_front/app/app.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Punto de entrada de Fylax.
///
/// Antes de arrancar la UI se inicializa:
/// 1. Inyección de dependencias (get_it).
/// 2. Datos de localización (fechas en español — Formatters).
/// 3. Supabase (auth + sesión persistente).
/// 4. Sentry (trazabilidad de errores desde el día uno — PRD §4).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  await initializeDateFormatting('es');

  // TODO(Fase 5/6): inicializar Supabase con anon-key y Sentry con DSN.
  // await Supabase.initialize(url: AppConstants.supabaseUrl, anonKey: ...);
  // await SentryFlutter.init(...);

  runApp(const FylaxApp());
}
