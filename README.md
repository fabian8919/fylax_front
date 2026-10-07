# Fylax — Frontend (Flutter)

App móvil de **salud financiera automática** (iOS y Android). Su diferenciador
frente a las apps de finanzas personales tradicionales es la captura 100%
automática de los gastos: el usuario nunca digita una transacción; el sistema
la detecta desde su correo (Gmail), la limpia con IA y la clasifica solo.

> Documento fuente del producto: [`docs/CONTEXT.md`](docs/CONTEXT.md)
> (contexto completo del aplicativo extraído del PRD v2.0).

## Stack

| Capa | Tecnología |
|-|-|
| Framework | Flutter (Dart ≥ 3.4) — una sola base de código para iOS/Android |
| Estado | Riverpod (providers asíncronos, ideal para el estado de sincronización en vivo) |
| Inyección de dependencias | get_it |
| Red | Dio (cliente REST hacia el backend FastAPI) |
| Navegación | go_router |
| Auth | Supabase Auth (proveedor Google OAuth, scope `gmail.readonly`) |
| Caché offline | Isar + shared_preferences + connectivity_plus |
| Monitoreo | Sentry |

## Arquitectura

**Clean Architecture** en tres capas estrictas por feature
(`lib/features/<feature>/{presentation,domain,data}`). Ninguna capa interna
depende de una externa:

- **Presentation**: widgets, providers de Riverpod y pantallas.
- **Domain**: entidades y casos de uso (sin dependencias de Flutter ni de red).
- **Data**: repositorios (implementación del patrón Repository), datasources
  remotos/locales y DTOs con mappers a entidades.

```
lib/
├── main.dart                # bootstrap: DI, Supabase, Sentry
├── app/                     # MaterialApp, router, tema, DI (get_it)
├── core/                    # constantes, errores, ApiClient, caché, utils
└── features/
    ├── auth/                # Épica 1: login Google + sesión
    ├── onboarding/          # Épica 1: 3 pantallas (valor, permiso, sync)
    ├── dashboard/           # Épica 3: balance, presupuesto, categorías
    ├── transactions/        # Épica 3: feed, formulario manual
    ├── sync/                # Épica 3: indicador de sincronización (F3.4)
    └── categories/          # categorías del sistema y personalizadas
```

## Estado del proyecto

Estructura base generada desde el PRD v2.0 (23-sep-2026). Los archivos
marcan con `TODO(Fase N)` los puntos de implementación según el plan de
fases del PRD §12:

1. **Fase 5 (app Flutter)**: registrar repositorios en `lib/app/di/injection.dart`,
   completar el flujo OAuth de Supabase y el interceptor de JWT en
   `core/network/api_client.dart`.
2. **Fase 6**: tests, Sentry y CI/CD.

## Puesta en marcha

```bash
# Requiere Flutter >= 3.22 (Dart >= 3.4)
flutter create . --project-name fylax_front   # genera carpetas de plataforma
flutter pub get
flutter run --dart-define=API_BASE_URL=... --dart-define=SUPABASE_URL=...
```

## Reglas de diseño clave (del PRD)

- El registro de transacciones es **silencioso por diseño**: cero
  notificaciones push por gasto. Las notificaciones solo llegarán con las
  recomendaciones y objetivos de ahorro futuros, y siempre accionables.
- UI minimalista: dashboard principal < 2 s, feed con scroll infinito y
  pull-to-refresh, gasto manual en ≤ 3 toques.
- El usuario siempre ve el estado de sincronización de su correo.
