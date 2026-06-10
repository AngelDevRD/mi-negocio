# Arquitectura — App Gestión Negocios

**Stack:** Flutter (Android + iOS) · Riverpod 3 (estado + DI) · Drift/SQLite (offline-first) · go_router · freezed · Supabase (desde F3).
**Patrón:** Clean Architecture por feature + Repository Pattern.

---

## 1. Estructura de carpetas

```
lib/
├── main.dart                  # ProviderScope + arranque
├── app.dart                   # MaterialApp.router + tema
├── core/                      # compartido por todos los features
│   ├── database/              # AppDatabase (Drift), tablas (F2), migraciones
│   ├── router/                # GoRouter + guards (licencia → auth → rol)
│   ├── theme/                 # AppTheme, AppSpacing
│   ├── utils/                 # Money, formateadores, validadores
│   ├── widgets/               # widgets reutilizables entre features
│   └── errors/                # Result<T> / Failure
└── features/<modulo>/
    ├── data/
    │   ├── daos/              # acceso Drift (queries del módulo)
    │   └── repositories/      # implementaciones de los contratos de domain
    ├── domain/
    │   ├── entities/          # modelos freezed del negocio
    │   ├── repositories/      # contratos (abstract class)
    │   └── usecases/          # lógica de aplicación (1 clase = 1 acción)
    └── presentation/
        ├── providers/         # providers Riverpod del módulo
        ├── screens/
        └── widgets/
```

## 2. Flujo de datos

```
UI (screen) → provider (Riverpod) → usecase → repository (contrato)
                                                  ↓
                                       repository_impl (data)
                                                  ↓
                                        DAO (Drift) → SQLite
```

- **Lecturas reactivas:** los DAOs exponen `Stream`s de Drift; los providers los
  consumen con `StreamProvider` — la UI se actualiza sola cuando otra pantalla escribe.
- **Escrituras:** siempre por usecase → repository. Las operaciones compuestas
  (venta, compra, cierre de caja) son UNA transacción Drift que incluye su registro
  de auditoría (patrón transversal, ver §5).
- **Errores:** los usecases devuelven `Result<T>` (`core/errors/result.dart`);
  las excepciones no cruzan hacia la UI.

## 3. Reglas de dependencia entre capas

| Capa | Puede importar | Prohibido |
|---|---|---|
| `domain` | `core/errors`, `core/utils` | Drift, Flutter UI, data, presentation |
| `data` | domain, `core/database` | presentation |
| `presentation` | domain, `core/*` | DAOs directamente (siempre vía usecase/repository) |
| `core` | — | features |

Un feature no importa internals de otro feature; si dos features comparten algo,
se promueve a `core/` o se expone vía contrato de domain.

## 4. Convenciones

- **Archivos:** `snake_case.dart`. Clases: `PascalCase`. Providers: `camelCaseProvider`.
- **Nombres de dominio en español** (entidades: `Producto`, `Venta`); código técnico en inglés.
- **Dinero:** SIEMPRE `Money` / `int` centavos (RNF-07). Nunca `double`.
- **IDs:** UUID v4 generado en el repositorio al insertar.
- **Timestamps:** `DateTime.now().toUtc()`, ISO-8601 en SQLite.
- **Soft delete:** columna `deleted_at`; las queries de lectura filtran `deleted_at IS NULL`.
- Codegen (`*.g.dart`, `*.freezed.dart`) nunca se edita a mano: `dart run build_runner build --delete-conflicting-outputs`.

## 5. Patrón de auditoría (transversal)

Los repositorios de escritura reciben el `userId` activo y escriben en la tabla
`auditoria` (F2) **dentro de la misma transacción** que el cambio. La Fase 14
solo agrega la pantalla de consulta.

## 6. Navegación

`core/router/app_router.dart` — un solo `GoRouter` con cadena de guards en `redirect`:

1. **Licencia** (F3): sin licencia → `/licencia/activar`; suspendida/vencida → `/licencia/bloqueada`.
2. **Auth** (F5): sin sesión → `/login`.
3. **Rol** (F5): rutas de admin (análisis, empleados, auditoría, respaldos, configuración) → cajero redirigido a `/`.

## 7. Inyección de dependencias

Riverpod es el contenedor de DI: `appDatabaseProvider` → `xxxDaoProvider` →
`xxxRepositoryProvider` (tipo del contrato de domain) → `xxxUsecaseProvider`.
En tests se sobreescriben con `ProviderScope(overrides: [...])` y
`AppDatabase.forTesting(NativeDatabase.memory())`.

## 8. Cómo agregar un feature nuevo

1. Crear `features/<modulo>/{data,domain,presentation}`.
2. Definir entidades freezed y el contrato del repositorio en `domain/`.
3. Implementar DAO + repositorio en `data/` (auditoría incluida en la transacción).
4. Exponer providers y pantallas en `presentation/`; registrar ruta en `app_router.dart`.
5. Tests: unitarios de repositorio/cálculos con DB en memoria + smoke test de pantalla.
6. Gate de fase: `flutter analyze` limpio + `flutter test` verde + prueba manual.
