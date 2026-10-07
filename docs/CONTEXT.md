# Contexto del aplicativo — Fylax (MVP App de Salud Financiera Automática)

> Fuente: PRD v2.0 — «PRD — MVP App de Salud Financiera Automática (SaaS)»,
> 23 de septiembre de 2026. Ingesta automatizada vía Gmail API ·
> Flutter (iOS/Android) + FastAPI + Supabase · IA: JEV · Pagos futuros: Wompi.
>
> Este documento consolida **todo el contexto del producto** para que cualquier
> desarrollador (o asistente de código) pueda trabajar en el frontend sin
> necesidad del PDF original.

---

## 1. Visión general del producto

Aplicación móvil de salud financiera (iOS y Android) estructurada como **SaaS**.
Su diferenciador frente a las apps de finanzas personales tradicionales es la
**captura 100% automática de los gastos**: el usuario nunca digita una
transacción; el sistema la detecta, la limpia con IA y la clasifica solo.

Para el MVP, el canal de captura será la **lectura automatizada del correo
electrónico del usuario (Gmail)**, donde llegan las alertas bancarias y los
recibos de comercios electrónicos. El backend consulta la Gmail API, extrae el
valor, el comercio, la fecha y el medio de pago con el motor de IA **JEV**, y
asienta la transacción en la base de datos.

Sobre esa base de datos, la app ofrece un **dashboard minimalista** con el
balance del mes, el gasto por categoría y el presupuesto restante, sentando las
bases para las funcionalidades de valor futuras: recomendaciones inteligentes y
objetivos de ahorro.

## 2. Objetivos del MVP y criterios de éxito

1. **Objetivo 1**: un usuario nuevo puede registrarse con Google (Supabase
   Auth), conceder permiso de lectura de Gmail y ver sus primeras
   transacciones detectadas automáticamente en **menos de 5 minutos**.
2. **Objetivo 2**: procesar correos de **al menos 3 fuentes distintas**
   (bancos y comercios) con una precisión de extracción **superior al 90%**
   en monto y comercio usando JEV.
3. **Objetivo 3**: garantizar **cero duplicados** de transacciones aunque el
   mismo correo se procese más de una vez (idempotencia).
4. **Objetivo 4**: dejar la base de datos y la autenticación preparadas para el
   modelo de suscripción SaaS (tiers **free / pro** con Wompi como pasarela de
   pago), sin necesidad de rediseñar esquemas después.

## 3. Alcance del MVP

### 3.1 Dentro del alcance

- Login con Google mediante Supabase Auth y solicitud del permiso
  `gmail.readonly`.
- Ingesta automática de transacciones desde Gmail con procesamiento
  **asíncrono** (Pub/Sub + Celery).
- Extracción y limpieza de datos con el motor de IA **JEV** (comercio, monto,
  fecha, medio de pago, categoría sugerida).
- Dashboard minimalista, feed de transacciones, creación/edición manual y
  estado de sincronización.
- Esquema de base de datos en Supabase (PostgreSQL) preparado para
  suscripciones con Wompi.

### 3.2 Fuera del alcance (fases posteriores)

- Recomendaciones inteligentes y objetivos de ahorro (cuando se activen,
  serán el **único origen de notificaciones al usuario** — ver sección 7).
- Soporte para Outlook / Microsoft Graph (segundo proveedor de correo).
- Cobro efectivo de suscripciones con Wompi (en el MVP solo se prepara el
  esquema; el paywall llega después).

## 4. Stack tecnológico completo

| Capa | Tecnología | Justificación |
|-|-|-|
| Frontend móvil | **Flutter (Dart)** | Una sola base de código para iOS y Android; UI moderna y minimalista. |
| Backend | **Python 3.12 + FastAPI** | Alto rendimiento asíncrono (asyncio) y ecosistema maduro de NLP e integración con IA. |
| ORM / migraciones | **SQLAlchemy 2 + Alembic** | Modelado relacional estricto y migraciones versionadas. |
| Base de datos | **PostgreSQL gestionado en Supabase** | Transacciones ACID (obligatorio para dinero), más Row Level Security y panel de administración incluido. |
| Gestión de usuarios / Auth | **Supabase Auth (proveedor Google OAuth)** | Entrega el access_token/refresh_token con el scope de Gmail y emite los JWT que verifica el backend. |
| Cola de tareas | **Celery + Redis** | Procesa correos y llamadas a la IA en background sin bloquear el servidor web. |
| Correo | **Gmail API + Google Cloud Pub/Sub** | Canal de ingesta del MVP: notificaciones push de correos nuevos. |
| Extracción con IA | **JEV** (motor de IA seleccionado por el equipo) | Convierte el cuerpo del correo en JSON estructurado: comercio, valor, fecha y medio de pago. |
| Nube | **Google Cloud Platform** | Cloud Run, Pub/Sub y Secret Manager: integración nativa con la Gmail API. |
| Pagos SaaS (preparación futura) | **Wompi** | Pasarela de pago colombiana; la BD se diseña desde ya con campos de suscripción para activar el cobro después sin rediseños. |
| Monitoreo | **Sentry + Cloud Logging** | Trazabilidad de errores en móvil y backend desde el día uno. |

## 5. Arquitectura y patrones de diseño

### 5.1 Frontend (Flutter)

- **Clean Architecture**: tres capas estrictas — Presentation (widgets y
  estado), Domain (entidades y casos de uso) y Data (repositorios y fuentes
  remotas/locales). Ninguna capa interna depende de una externa.
- **Gestión de estado — Riverpod**: recomendado por su escalabilidad,
  testabilidad y soporte para providers asíncronos (ideal para el estado de
  sincronización en vivo).
- **Patrón Repository**: la UI nunca habla directo con la API; los
  repositorios abstraen el origen del dato (REST remoto vs. caché local en
  SQLite/Isar) y permiten modo offline.
- **Inyección de dependencias — get_it**: registro de repositorios, casos de
  uso y clientes HTTP para facilitar pruebas con mocks.
- **DTOs y mappers**: los modelos JSON de la API nunca llegan a la UI; se
  mapean a entidades de dominio.

### 5.2 Backend (FastAPI)

- **Monolito modular**: un solo servicio desplegable, separado internamente
  por dominios: users, transactions, integrations (gmail), billing. Facilita
  migrar a microservicios en el futuro sin reescribir.
- **Patrón Strategy / Factory**: cada remitente financiero tiene su parser
  (BancolombiaParser, AmazonParser, AviancaParser…). Un factory selecciona el
  parser según el dominio del remitente; si no existe, se usa JEV como parser
  genérico.
- **Patrón Observer / Webhooks**: el endpoint `/webhooks/gmail` reacciona a las
  notificaciones de Pub/Sub. Responde HTTP 200 en menos de 300 ms y delega el
  trabajo pesado a la cola.
- **DTO estricto con Pydantic**: todos los cuerpos de entrada y salida de la
  API se validan con modelos Pydantic; el JSON que devuelve JEV también se
  valida contra un schema antes de tocar la base de datos.
- **Separación Web / Workers (ADR clave)**: las llamadas a la Gmail API y a
  JEV pueden tardar varios segundos; jamás se ejecutan en el hilo del servidor
  web. FastAPI encola la tarea en Redis y Celery la procesa en background, con
  reintentos y escalado independiente.

### 5.3 Flujo de ingesta (resumen operativo)

1. El banco o comercio envía el recibo al correo del usuario.
2. Gmail notifica a Google Cloud Pub/Sub, que dispara un POST al webhook del
   backend.
3. El backend encola `process_new_email(user_id)` en Celery y responde 200 OK.
4. El worker descarga el correo con la Gmail API (usando el refresh_token
   desencriptado).
5. El parser correspondiente (o JEV como parser genérico) extrae
   `{merchant, amount, date, currency, payment_method, category}`.
6. Se valida el JSON con Pydantic y se inserta la transacción; la restricción
   UNIQUE `(user_id, source_ref_id)` evita duplicados.

## 6. Funcionalidades críticas (épicas e historias)

### Épica 1 — Autenticación y onboarding

| ID | Funcionalidad | Criterio de aceptación |
|-|-|-|
| F1.1 | Login seguro con "Sign in with Google" usando Supabase Auth en Flutter; el backend verifica el JWT emitido por Supabase en cada petición. | El usuario entra sin crear contraseña; el backend rechaza tokens inválidos con 401. |
| F1.2 | Durante el flujo OAuth de Supabase (proveedor Google) se solicita explícitamente el scope `https://www.googleapis.com/auth/gmail.readonly` (solo lectura, nada de escritura ni borrado). | El consent screen muestra únicamente el permiso de lectura; sin él, la app muestra un mensaje explicativo. |
| F1.3 | El backend recibe el refresh_token de Google (provider_token de Supabase) y lo almacena encriptado con AES-256-GCM en la tabla users; la llave vive en Google Secret Manager. | El token nunca aparece en texto plano en la BD, en logs ni en el código fuente. |
| F1.4 | Onboarding de 3 pantallas: propuesta de valor, permiso de correo y primera sincronización. | Un usuario nuevo completa el flujo en menos de 5 minutos. |

### Épica 2 — Motor de ingesta automatizada (núcleo del producto)

| ID | Funcionalidad | Criterio de aceptación |
|-|-|-|
| F2.1 | Suscripción del backend a Google Cloud Pub/Sub: se registra un watch por usuario sobre su bandeja de entrada y se renueva antes de su expiración (7 días). | Tras el login, un correo nuevo de prueba genera una notificación al webhook en menos de 60 segundos. |
| F2.2 | Filtrado de correos: consultas a la Gmail API con queries específicas (dominios bancarios, asuntos de recibo/factura) usando el historyId para traer solo correos nuevos. | Correos personales o promocionales sin datos de pago nunca generan transacciones. |
| F2.3 | Extracción con IA: el cuerpo del correo (HTML/texto plano) se envía a JEV con un system prompt estricto que exige salida JSON `{merchant, amount, date, currency, payment_method, suggested_category}`; el resultado se valida con Pydantic. | Precisión ≥ 90% en monto y comercio sobre un set de prueba de al menos 30 correos reales anonimizados. |
| F2.4 | Parsers deterministas (Strategy) para los remitentes más frecuentes, con JEV como respaldo genérico. | Los remitentes con parser propio se procesan sin llamada a JEV (costo cero). |
| F2.5 | Procesamiento asíncrono con Celery: reintentos con backoff exponencial, dead-letter queue para correos fallidos y registro de errores en Sentry. | El webhook responde 200 en < 300 ms; un correo fallido se reintenta 3 veces y luego queda registrado. |
| F2.6 | Idempotencia: restricción UNIQUE `(user_id, source_ref_id)` en la tabla de transacciones. | Procesar el mismo correo dos veces jamás duplica el gasto. |

### Épica 3 — Interfaz de usuario (Flutter)

| ID | Funcionalidad | Criterio de aceptación |
|-|-|-|
| F3.1 | Dashboard minimalista: balance del mes, dinero disponible (presupuesto restante) y distribución por categoría. | La pantalla principal carga en < 2 segundos con datos del día. |
| F3.2 | Feed de transacciones: lista paginada con tarjetas que muestran comercio limpio, ícono de categoría, monto y fecha. | Scroll infinito fluido; pull-to-refresh actualiza el feed. |
| F3.3 | Creación y edición manual: formulario rápido para gastos en efectivo y corrección de categoría o comercio de cualquier transacción. | Agregar un gasto manual toma ≤ 3 toques. |
| F3.4 | Indicador de sincronización: estado visible "Sincronizando correos…" / "Última actualización hace X min" / error con acción de reintento. | El usuario siempre sabe si su correo está conectado y al día. |

### Épica 4 — Preparación SaaS con Wompi (sin paywall todavía)

| ID | Funcionalidad | Criterio de aceptación |
|-|-|-|
| F4.1 | Campo `subscription_tier` (free \| pro) en users y middleware de límites: el tier free procesa hasta N correos/mes. | El backend puede limitar por tier aunque el cobro aún no esté activo. |
| F4.2 | Esquema de base de datos compatible con Wompi (`wompi_customer_id`, estado de suscripción), listo para activar el paywall sin migraciones destructivas. | Integrar Wompi después solo requiere poblar campos existentes y agregar el endpoint de webhook de eventos de pago. |

## 7. Regla de notificaciones

La aplicación **NO envía notificaciones por cada gasto registrado
automáticamente**. El registro de transacciones es **silencioso por diseño**:
el usuario consulta su actividad en el feed cuando lo desee, sin
interrupciones.

Las notificaciones push al usuario se activan únicamente cuando se activen las
funcionalidades de recomendaciones inteligentes y/u objetivos de ahorro (fases
posteriores al MVP). En ese momento, la app notificará solo eventos de valor:
por ejemplo, una recomendación ("a este ritmo de gasto en domicilios te
faltarán $200.000 para tus gastos fijos") o el avance/cumplimiento de un
objetivo ("llevas el 60% de tu meta de ahorro para vehículo").

**Criterio de diseño para esa fase**: toda notificación debe ser accionable,
configurable (el usuario puede silenciar cada tipo) y nunca redundante con
información que ya está visible en el dashboard.

## 8. Modelo de base de datos

PostgreSQL gestionado en Supabase, **multitenant** (todos los registros cuelgan
de `user_id`), con **Row Level Security (RLS)** activado por tabla para que
ningún usuario pueda leer datos ajenos, montos en **Decimal** y restricciones
de unicidad para idempotencia:

| Tabla | Campos principales |
|-|-|
| `users` | id (UUID, PK, enlazado a Supabase Auth), email (único), name, google_refresh_token (encriptado AES-256-GCM), subscription_tier (free \| pro), wompi_customer_id (nullable, preparación futura), created_at |
| `categories` | id (PK), name, icon, color, type (income \| expense), is_system_default |
| `transactions` | id (UUID, PK), user_id (FK), category_id (FK), amount (Decimal 10,2), currency (ISO 4217, ej. COP), date (timestamp), merchant_clean, source (manual \| gmail_api), source_ref_id (ID del correo), created_at. Restricción UNIQUE (user_id, source_ref_id) |
| `email_sync_state` | user_id (FK), gmail_history_id (último historyId procesado), last_sync_at, status (active \| error \| revoked) |

## 9. Endpoints principales de la API

| Endpoint | Método | Descripción |
|-|-|-|
| `/auth/session` | POST | Registra/actualiza el usuario en la base de datos a partir del JWT de Supabase Auth (que incluye los tokens de Google). |
| `/webhooks/gmail` | POST | Recibe las notificaciones Push de Pub/Sub y encola la tarea de procesamiento. |
| `/transactions` | GET | Lista paginada de transacciones del usuario (filtros por fecha, categoría, fuente). |
| `/transactions` | POST | Crea una transacción manual (efectivo u otros). |
| `/transactions/{id}` | PATCH | Edita monto, categoría o comercio de una transacción. |
| `/transactions/{id}` | DELETE | Elimina una transacción. |
| `/categories` | GET | Lista las categorías del sistema y las personalizadas. |
| `/dashboard/summary` | GET | Balance del mes, gasto por categoría y presupuesto restante. |
| `/sync/status` | GET | Estado de la sincronización de correo (última actualización, errores). |

Todas las rutas (excepto `/webhooks/gmail` y `/auth/session`) exigen el JWT de
Supabase Auth verificado. La documentación interactiva queda disponible
automáticamente en `/docs` gracias a FastAPI (OpenAPI/Swagger).

## 10. Seguridad y cumplimiento

- **Tokens encriptados**: refresh_tokens de Google con AES-256-GCM; llaves en
  Google Secret Manager inyectadas como variables de entorno en despliegue,
  nunca en el repositorio.
- **Row Level Security**: políticas RLS en Supabase que limitan cada fila a su
  user_id, como segunda línea de defensa además de la validación del backend.
- **Mínimos privilegios**: únicamente el scope `gmail.readonly`, lo que
  simplifica la verificación de la app ante Google (OAuth App Verification).
- **Idempotencia y reintentos**: UNIQUE (user_id, source_ref_id) más reintentos
  con backoff; ningún gasto se cobra dos veces.
- **Privacidad**: los cuerpos de correo se procesan en memoria y no se
  persisten; solo se guarda la transacción estructurada resultante. Política de
  privacidad publicada desde el MVP (requisito de Google).
- **Transporte**: HTTPS extremo a extremo; el webhook de Pub/Sub valida el
  token de verificación de Google en cada llamada.

## 11. Infraestructura y plataformas

- **API web**: Google Cloud Run (contenedor Docker, autoescalado de 0 a N
  instancias — costo cero sin tráfico).
- **Workers Celery**: Cloud Run en modo background o una instancia Compute
  Engine e2-micro.
- **Base de datos y usuarios**: Supabase (PostgreSQL gestionado + Supabase
  Auth), capa gratuita para el MVP.
- **Cola / caché**: Upstash Redis (capa gratuita) en la fase inicial; migrar a
  Memorystore cuando el volumen lo justifique.
- **Eventos**: Google Cloud Pub/Sub para las notificaciones push de Gmail.
- **Secretos**: Google Secret Manager; CI/CD con GitHub Actions (lint, tests,
  build de Docker y despliegue a Cloud Run).
- **Distribución móvil**: Google Play Console (pruebas internas) para Android y
  TestFlight para iOS, antes del lanzamiento público.

## 12. Plan de desarrollo por fases (instrucciones para Kimi)

Contexto para el asistente de código: actúa como un Ingeniero de Software
Senior (Staff Engineer). Entrega el código en **fases cerradas y verificables,
sin mezclar capas**:

1. **Fase 1 — Base del backend**: estructura del monolito modular en FastAPI,
   modelos SQLAlchemy, migraciones con Alembic, conexión a Supabase Postgres y
   configuración de entornos (dev/staging/prod).
2. **Fase 2 — Autenticación**: flujo OAuth de Google a través de Supabase Auth
   (con scope gmail.readonly), verificación del JWT de Supabase y
   almacenamiento encriptado del refresh_token.
3. **Fase 3 — Ingesta Gmail**: watch + webhook de Pub/Sub, lectura incremental
   con historyId, parsers Strategy y pipeline de extracción con JEV validado
   por Pydantic, todo en workers Celery con idempotencia.
4. **Fase 4 — API de consulta**: endpoints de transacciones, categorías,
   dashboard y estado de sincronización, con paginación y filtros.
5. **Fase 5 — App Flutter**: proyecto con Clean Architecture + Riverpod;
   pantallas de login/onboarding, dashboard, feed y formulario manual,
   consumiendo la API real.
6. **Fase 6 — Endurecimiento**: tests de precisión de los parsers y de JEV,
   monitoreo con Sentry, CI/CD y despliegue a Cloud Run.

> **Responsabilidad de este repositorio (`fylax_front`):** Fases 5 y 6
> (frontend Flutter). El progreso pendiente está marcado con `TODO(Fase N)`
> en el código.

## 13. Riesgos y mitigaciones

- **Verificación OAuth de Google**: el scope de Gmail exige pasar la revisión
  de Google. Mitigación: solicitar solo lectura, publicar política de
  privacidad y preparar el video demo desde ya.
- **Formatos de correo cambiantes**: los bancos modifican sus plantillas.
  Mitigación: parsers versionados por remitente, JEV como respaldo genérico y
  monitoreo de tasa de fallo por parser.
- **Costos del motor de IA**: mitigación: parsers deterministas primero; JEV
  solo para remitentes desconocidos o correos que el parser determinista no
  logra resolver.
- **Expiración del watch de Gmail (7 días)**: tarea programada (Cloud Scheduler
  + Celery beat) que renueva el watch de cada usuario diariamente.

---

## Anexo A — Mapa de la estructura del frontend

Correspondencia entre épicas del PRD y features del proyecto Flutter:

| Épica / historia | Feature en `lib/features/` | Archivos clave |
|-|-|-|
| F1.1–F1.2 Login Google + scope gmail.readonly | `auth` | `presentation/screens/login_screen.dart`, `data/datasources/auth_remote_datasource.dart` |
| F1.4 Onboarding 3 pantallas | `onboarding` | `presentation/screens/onboarding_screen.dart` |
| F3.1 Dashboard minimalista | `dashboard` | `presentation/screens/dashboard_screen.dart`, `widgets/balance_card.dart`, `widgets/category_distribution.dart` |
| F3.2 Feed paginado | `transactions` | `presentation/screens/transactions_feed_screen.dart`, `widgets/transaction_card.dart`, `presentation/providers/transactions_provider.dart` |
| F3.3 Creación/edición manual | `transactions` | `presentation/screens/transaction_form_screen.dart` |
| F3.4 Indicador de sincronización | `sync` | `presentation/widgets/sync_status_indicator.dart`, `domain/entities/sync_status.dart` |
| GET /categories | `categories` | `presentation/providers/categories_provider.dart` |
| JWT de Supabase en cada petición | `core` | `core/network/api_client.dart` |
| Manejo de errores / modo offline | `core` | `core/errors/failure.dart`, `core/storage/local_cache.dart` |
