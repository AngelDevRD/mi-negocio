# Multiplataforma (Android / Windows / iOS) y CI/CD con Codemagic

Estado: la app compila desde una única base de código Flutter para Android, Windows
(escritorio) e iOS. La compilación de iOS requiere una Mac remota — se resuelve con
Codemagic (`mac_mini_m2`), sin necesidad de tener un Mac físico.

## 1. Informe de compatibilidad

Todas las dependencias del `pubspec.yaml` son plugins federados que declaran soporte
`android / ios / windows` (o son puro-Dart, sin código nativo), así que no fue necesario
reemplazar ninguna:

| Paquete | Android | iOS | Windows | Nota |
|---|---|---|---|---|
| drift + drift_flutter | ✅ | ✅ | ✅ | usa `driftDatabase()`, ya portable |
| image_picker | ✅ | ✅ | ⚠️ sin cámara | ver punto 2.1 |
| flutter_local_notifications | ✅ | ✅ | ⚠️ requiere config extra | ver punto 2.2 |
| flutter_secure_storage | ✅ (Keystore) | ✅ (Keychain) | ✅ (DPAPI) | sin cambios |
| device_info_plus / connectivity_plus | ✅ | ✅ | ✅ | sin cambios |
| file_picker / share_plus / url_launcher / printing | ✅ | ✅ | ✅ | sin cambios |
| path_provider / package_info_plus / shared_preferences | ✅ | ✅ | ✅ | sin cambios |
| supabase_flutter / http / cryptography / archive / excel / pdf / csv / fl_chart | ✅ | ✅ | ✅ | puro Dart o HTTP, sin binarios nativos |

No se detectaron dependencias incompatibles con iOS. No se quitó ni reemplazó ningún
paquete.

### 2.1 `image_picker` — cámara no existe en Windows/macOS/Linux

El plugin no implementa `ImageSource.camera` en escritorio (solo Android/iOS). El botón
"Tomar foto" se mostraba siempre. Se ajustó para mostrarse solo en Android/iOS, dejando
"Galería" (que sí existe en todas las plataformas vía selector de archivos) siempre visible.
Archivos:
- [purchase_form_screen.dart](../lib/features/purchases/presentation/screens/purchase_form_screen.dart)
- [profile_screen.dart](../lib/features/profile/presentation/screens/profile_screen.dart)
- [employee_form_screen.dart](../lib/features/employees/presentation/screens/employee_form_screen.dart)

Ningún flujo de negocio cambió: en Android/iOS el comportamiento es idéntico al anterior.

### 2.2 `flutter_local_notifications` — Windows necesita `WindowsInitializationSettings`

Sin ese bloque, `show()` falla en Windows (falta el AUMID/GUID que identifica la app ante
el sistema de notificaciones). Se agregó `WindowsInitializationSettings` (y también
`macOS`/`linux` por completitud) en
[notification_service.dart](../lib/core/services/notification_service.dart).

> Nota real de la plataforma (no corregible desde el código): en Windows las
> notificaciones solo se muestran de forma fiable cuando la app corre desde un acceso
> directo instalado con el AUMID registrado (no en `flutter run` en modo debug). En un
> `.exe` distribuido normalmente (o instalado con MSIX) funciona sin problema.

### 2.3 Identidad de la app — bundle id de iOS

`ios/Runner.xcodeproj` traía el identificador placeholder `com.example.appGestion`
(Apple rechaza `com.example.*` al subir a App Store Connect). Se cambió a
`com.angeldevrd.appgestion`, igual al `applicationId` de Android, para que ambas tiendas
identifiquen la misma app.

### 2.4 Branding del ejecutable de Windows

`windows/runner/Runner.rc` y `windows/runner/main.cpp` traían el nombre por defecto
`app_gestion` (título de ventana, `ProductName`, `FileDescription`). Se cambiaron a
"MiTienda 360" para que coincida con `android:label` en el manifest de Android.

### 2.5 Firma de Android para release

`android/app/build.gradle.kts` firmaba el `release` con la key de debug (funciona para
probar, pero Google Play la rechaza). Se agregó un `signingConfig` que lee
`CM_KEYSTORE_PATH` / `CM_KEYSTORE_PASSWORD` / `CM_KEY_ALIAS` / `CM_KEY_PASSWORD` (variables
que Codemagic inyecta automáticamente cuando subes un keystore en
**Code signing identities**). Si esas variables no existen (build local sin CI), cae de
vuelta a la firma debug — nada se rompe en `flutter run` local.

### 2.6 `AppUpdater` (actualizador propio) — revisar antes de publicar en tiendas

[app_updater.dart](../lib/core/app_updater.dart) (ya existía sin commitear, no se tocó su
lógica) abre una URL de descarga de APK cuando hay versión nueva. Esto tiene sentido para
distribución directa (APK/EXE fuera de tienda), pero:
- **App Store (iOS)**: Apple prohíbe mecanismos de actualización que evadan App Store. El
  diálogo en sí (link externo) no viola la política por sí solo, pero **no debe apuntar a
  un instalable**; para builds de App Store conviene omitir la llamada a
  `AppUpdater.checkForUpdate` o apuntar el link al listado de App Store.
- **Windows**: el `apk_url` no aplica; si se reutiliza este flujo para Windows, el backend
  del portafolio necesita devolver también un `exe_url`/`zip_url` según plataforma.

Esto es una decisión de producto, no se modificó — queda como pendiente a decidir antes de
publicar en App Store.

## 3. Soporte Windows agregado

Se generó la plataforma con `flutter create --platforms=windows .`, que creó `windows/`
completo (CMake, runner Win32, icono). No tocó `pubspec.yaml` ni ningún archivo de Dart.

Compilar localmente:
```powershell
flutter config --enable-windows-desktop
flutter build windows --release
# ejecutable en build\windows\x64\runner\Release\app_gestion.exe
```

## 4. `codemagic.yaml` — 3 workflows

Archivo: [codemagic.yaml](../codemagic.yaml) en la raíz del repo.

| Workflow | Instancia | Genera |
|---|---|---|
| `android-workflow` | Linux | `.apk` (release firmado) + `.aab` (Google Play) |
| `ios-workflow` | Mac mini M2 (remota, provista por Codemagic) | `.ipa` |
| `windows-workflow` | Windows | `.exe` empaquetado en `.zip` |

Todos pasan `SUPABASE_URL` / `SUPABASE_ANON_KEY` vía `--dart-define`, tomados del grupo de
variables `supabase_credentials` (nunca hardcodeados — la app ya estaba diseñada así, ver
`lib/core/config/supabase_config.dart`). Sin esas variables la app sigue funcionando en
modo local/demo, como ya documentaba el código original.

Caché: Codemagic cachea `~/.pub-cache` y el Gradle/CocoaPods cache automáticamente por
proyecto entre builds; no requiere configuración manual adicional en `codemagic.yaml`.

## 5. Conectar el repositorio a Codemagic — pasos

1. Sube este repo a GitHub (si no está ya) y haz push de esta rama.
2. Entra a https://codemagic.io → **Add application** → conecta tu cuenta de GitHub →
   selecciona el repositorio `mi-negocio`.
3. Codemagic detecta `codemagic.yaml` automáticamente (build config = "codemagic.yaml en
   el repositorio").
4. **Variables de entorno** (Codemagic → tu app → Environment variables):
   - Crea el grupo `supabase_credentials` con `SUPABASE_URL` y `SUPABASE_ANON_KEY`
     (marca "Secure" en la anon key si prefieres, aunque es pública por diseño).
5. **Firma de Android** (Codemagic → tu app → Code signing identities → Android):
   - Sube tu keystore `.jks`/`.keystore`, alias y contraseñas. Nómbralo
     `mitienda360_keystore` (o ajusta el nombre en `codemagic.yaml`).
   - Si aún no tienes un keystore de release, genera uno con:
     ```
     keytool -genkey -v -keystore mitienda360-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mitienda360
     ```
6. **Firma de iOS** (Codemagic → tu app → Code signing identities → iOS): ver sección 6,
   requiere tu cuenta de Apple Developer.
7. Corre el workflow que quieras manualmente desde el dashboard ("Start new build"), o
   configura un trigger automático (push a `main`, tag, etc.) en **Workflow editor**.

## 6. Lo que solo tú puedes proporcionar (cuenta/credenciales Apple)

Nada de esto se inventó ni se dejó hardcodeado. Pendiente de tu parte antes de que
`ios-workflow` pueda producir un `.ipa` firmado:

1. **Cuenta de Apple Developer Program** activa (99 USD/año) — necesaria para firmar y
   subir a TestFlight/App Store.
2. **App Store Connect API Key** (recomendado, es lo que usa `auth: integration` en el
   yaml): en App Store Connect → Users and Access → Integrations → App Store Connect API
   → genera una key con rol "App Manager", descarga el `.p8` y anota `Issuer ID` y
   `Key ID`. Se sube en Codemagic → Team settings → **Integrations → App Store Connect**.
3. **Registrar la app en App Store Connect** con el bundle id `com.angeldevrd.appgestion`
   (el mismo que ya quedó configurado en el proyecto).
4. Con la integración de App Store Connect conectada, Codemagic puede generar
   automáticamente el certificado de distribución y el provisioning profile (no hace
   falta que los subas a mano) — por eso el workflow usa `distribution_type: app_store` +
   `xcode-project use-profiles` en vez de certificados manuales.
5. Decisión de producto pendiente: qué hacer con `AppUpdater` en la build de App Store
   (punto 2.6 arriba).

Sin estos 4 puntos, `android-workflow` y `windows-workflow` funcionan igual — solo
`ios-workflow` queda bloqueado hasta que los proporciones.

## 7. Resumen de archivos modificados/creados en este cambio

- `windows/**` (nuevo) — plataforma Windows generada por `flutter create`.
- `codemagic.yaml` (nuevo) — 3 workflows de CI/CD.
- `docs/MULTIPLATAFORMA_CI.md` (nuevo) — este documento.
- `lib/core/services/notification_service.dart` — init de notificaciones en Windows/macOS/Linux.
- `lib/features/purchases/presentation/screens/purchase_form_screen.dart`,
  `lib/features/profile/presentation/screens/profile_screen.dart`,
  `lib/features/employees/presentation/screens/employee_form_screen.dart` — ocultan
  "Tomar foto" en escritorio (image_picker no soporta cámara ahí).
- `ios/Runner.xcodeproj/project.pbxproj` — bundle id `com.example.appGestion` →
  `com.angeldevrd.appgestion`.
- `windows/runner/Runner.rc`, `windows/runner/main.cpp` — branding "MiTienda 360".
- `android/app/build.gradle.kts` — signing config de release listo para CI (keystore vía
  variables de entorno, con fallback a debug en local).

No se modificó ninguna regla de negocio, pantalla, modelo de datos ni flujo existente más
allá de lo listado arriba.
