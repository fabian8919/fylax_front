# Pendiente — estado operativo del front y cómo probar

> Estado al **17-nov-2026**. Documento operativo para retomar la sesión.
> El estado del pipeline de ingesta vive en
> `fylax_back/docs/PENDIENTES_SETUP.md`.

## ✅ Login Google end-to-end: VERIFICADO (14-nov-2026)

Probado en teléfono físico (Xiaomi Mi 10T, MIUI) contra el proyecto
definitivo de Supabase (`phfprgocglekorhkapvw`):

1. OAuth de Google → consent screen `gmail.readonly` → deep link
   `io.supabase.flutter://login-callback` de vuelta a la app.
2. `POST /api/v1/auth/session` creó el usuario con `google_refresh_token`
   cifrado (AES-256-GCM) y `email_sync_state` activo (verificado en la DB).

## Configuración del front (`.env` — nunca commitear)

```
API_BASE_URL=http://<IP-LAN-del-PC>:8000/api/v1   # CON el prefijo /api/v1
SUPABASE_URL=https://phfprgocglekorhkapvw.supabase.co
SUPABASE_ANON_KEY=<anon public key del proyecto>
```

- `10.0.2.2` en lugar de la IP-LAN solo funciona desde el **emulador**.
- **El `.env` se empaqueta al compilar**: tras editarlo hay que hacer
  `flutter run` / `flutter build` completo (el hot reload no lo recarga).
- Android debug permite HTTP en claro (`usesCleartextTraffic` solo en
  `android/app/src/debug/AndroidManifest.xml`) para hablar con el back
  local sin HTTPS; release sigue siendo HTTPS-only.

## Cómo probar en el teléfono físico (sin emulador)

1. Los 4 procesos del back deben estar corriendo (ver doc del back):
   API (`python -m app`), túnel cloudflared, worker Celery y beat; y el
   teléfono en la misma WiFi del PC.
2. Con USB: `flutter run -d <id-del-teléfono>` (`flutter devices` lo lista).
3. Sin depuración (APK instalado):
   ```
   flutter build apk --debug
   adb install -r build\app\outputs\flutter-apk\app-debug.apk
   ```
   MIUI exige activar **"Instalar mediante USB"** en Opciones de
   desarrollador y confirmar el diálogo en el teléfono; sin eso falla con
   `INSTALL_FAILED_USER_RESTRICTED`.
4. Alternativa sin cable: **Depuración inalámbrica** en el teléfono +
   `adb pair <ip-cel>:<puerto>` y `adb connect <ip-cel>:<puerto>`.

## Prueba pendiente (Épica 2)

- Enviarse/recibir una alerta real de Bancolombia, Amazon o Avianca → la
  transacción debe aparecer sola en el dashboard. Los correos de Nequi
  aún no generan transacción (falta JEV o un parser de `nequi.com.co`).
