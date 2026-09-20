# MiTienda 360

Gestión para colmados y pequeños negocios de barrio, hecha para funcionar **sin
internet**. Todo se guarda en el equipo y, cuando hay conexión, se sincroniza.

Flutter · Android y Windows · Español (República Dominicana), montos en RD$.

## Qué hace

- **Ventas rápidas.** Buscas el producto, lo agregas y cobras. Efectivo, tarjeta,
  transferencia o fiado, con cálculo del cambio y botones de billetes.
- **Fiado.** Clientes con su cuenta, abonos, límite de crédito y cuánto te deben.
- **Caja.** Apertura y cierre con arqueo por método de pago, entradas y salidas
  manuales, y el faltante o sobrante antes de confirmar el cierre.
- **Productos e inventario.** Stock, ajustes con motivo, historial de movimientos,
  alertas de stock mínimo y categorías.
- **Compras y gastos**, con anulación y su efecto en la caja.
- **Empleados** y sus pagos; **usuarios** con rol de administrador o cajero.
- **Análisis** del negocio: ventas, ganancia, rankings y comparación entre meses.
- **Auditoría** de quién hizo cada cosa.
- **Datos:** respaldo completo, restauración, exportación a Excel, PDF o CSV e
  importación desde archivo.
- **Asistente con IA** para preguntas sobre el negocio.

## Cómo se construyó

Riverpod, go_router y Drift (SQLite) sobre una arquitectura por capas
(`data` / `domain` / `presentation`), con sincronización offline-first hacia
Supabase mediante una cola con reintentos.

La calidad se sostiene con ~930 pruebas automatizadas y un banco de capturas
(`test_visual/`) que dibuja cada pantalla en teléfono, tablet y escritorio, con
texto normal y agrandado, para detectar textos cortados o desbordes.

## Correr el proyecto

```bash
flutter pub get
flutter run
```

Pruebas y análisis:

```bash
flutter analyze
flutter test
flutter test test_visual --update-goldens   # capturas en build/visual/
```

Las claves de Supabase se pasan por `--dart-define`; no hay credenciales en el
repositorio.
