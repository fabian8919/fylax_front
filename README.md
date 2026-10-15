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
├── core/                    # constantes, errores, ApiClient (JWT), caché, utils
└── features/
    ├── auth/                # Épica 1: login Google + sesión persistente
    ├── onboarding/          # Épica 1: 3 pantallas (valor, permiso, sync)
    ├── dashboard/           # Épica 3: balance, presupuesto, categorías
    ├── transactions/        # Épica 3: feed, formulario manual
    ├── goals/               # propósitos de ahorro (CRUD + aportes)
    ├── sync/                # Épica 3: indicador de sincronización (F3.4)
    └── categories/          # categorías del sistema y personalizadas
```

## Estado del proyecto

Fase 5 **implementada** (14-oct-2026): la app corre en dos modos según la
configuración (`AppConstants.isBackendConfigured`):

- **Backend real** (con `SUPABASE_ANON_KEY`): OAuth de Google vía Supabase
  Auth (scope `gmail.readonly`, `access_type=offline` para el refresh
  token), `POST /auth/session`, interceptor que adjunta el JWT en cada
  petición y lo refresca una vez ante 401, sesión persistente al reabrir
  la app y repositorios remotos para categorías, transacciones, dashboard,
  propósitos y sync.
- **Demo** (sin anon-key): repositorios en memoria, app navegable de punta
  a punta sin backend.

Pendiente — Fase 6: tests, Sentry y CI/CD.

## Puesta en marcha

```bash
# Requiere Flutter >= 3.22 (Dart >= 3.4)
flutter create . --project-name fylax_front   # genera carpetas de plataforma
flutter pub get

# Modo backend real (emulador Android → backend local en tu PC):
flutter run --dart-define=SUPABASE_ANON_KEY=<anon-key-del-proyecto>
# API_BASE_URL ya apunta a http://10.0.2.2:8000/api/v1 por defecto
# (10.0.2.2 = localhost del PC visto desde el emulador).

# Dispositivo físico en la misma red Wi-Fi:
flutter run --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=API_BASE_URL=http://<ip-de-tu-pc>:8000/api/v1

# Modo demo (sin backend):
flutter run
```

La anon-key está en Supabase → **Project Settings → API → anon public key**
(es pública por diseño; la seguridad real la dan RLS + el JWT).
Prerequisito: el backend corriendo (`uvicorn app.main:app --reload` en
`fylax_back`) con el `.env` configurado.

## Reglas de diseño clave (del PRD)

- El registro de transacciones es **silencioso por diseño**: cero
  notificaciones push por gasto. Las notificaciones solo llegarán con las
  recomendaciones y objetivos de ahorro futuros, y siempre accionables.
- UI minimalista: dashboard principal < 2 s, feed con scroll infinito y
  pull-to-refresh, gasto manual en ≤ 3 toques.
- El usuario siempre ve el estado de sincronización de su correo.
