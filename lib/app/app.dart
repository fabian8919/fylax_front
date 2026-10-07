import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Raíz de la aplicación (PRD §5.1 — capa Presentation).
class FylaxApp extends StatelessWidget {
  const FylaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Fylax',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        // Fylax es dark-first: paleta negro/azul/verde (PRD §4).
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.config,
      ),
    );
  }
}
