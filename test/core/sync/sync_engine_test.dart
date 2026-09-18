import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/sync/sync_engine.dart';
import 'package:app_gestion/core/sync/sync_queue_writer.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Destino remoto falso: registra cada intento y falla en las tablas
/// indicadas.
class _RemotoFalso implements SyncRemote {
  @override
  String? userId = 'usuario-1';

  final intentos = <String>[];
  final filas = <Map<String, dynamic>>[];
  final tablasQueFallan = <String>{};

  int intentosDe(String tabla) =>
      intentos.where((i) => i.startsWith('$tabla/')).length;

  @override
  Future<void> upsert(String tabla, Map<String, dynamic> fila) async {
    intentos.add('$tabla/${fila['id']}');
    filas.add(fila);
    if (tablasQueFallan.contains(tabla)) {
      throw StateError('la tabla $tabla no existe en el servidor');
    }
  }

  @override
  Future<void> delete(String tabla, String id) async {
    intentos.add('$tabla/$id');
    if (tablasQueFallan.contains(tabla)) throw StateError('falla $tabla');
  }
}

void main() {
  group('esperaReintento (función pura)', () {
    test('sin intentos no hay espera', () {
      expect(esperaReintento(0), Duration.zero);
    });

    test('n=1 -> 30 s, n=2 -> 60 s, y se duplica', () {
      expect(esperaReintento(1), const Duration(seconds: 30));
      expect(esperaReintento(2), const Duration(seconds: 60));
      expect(esperaReintento(3), const Duration(seconds: 120));
      expect(esperaReintento(4), const Duration(seconds: 240));
    });

    test('tiene un tope de 6 horas', () {
      // 30 s * 2^9 = 4 h 16 min todavía no llega al tope...
      expect(esperaReintento(10), const Duration(seconds: 15360));
      // ...y desde el intento 11 se topa.
      expect(esperaReintento(11), const Duration(hours: 6));
      expect(esperaReintento(50), const Duration(hours: 6));
      expect(esperaReintento(100000), const Duration(hours: 6));
    });
  });

  group('tocaReintentar', () {
    final t0 = DateTime.utc(2026, 1, 1, 12);

    test('una fila nueva (0 intentos) siempre toca', () {
      expect(tocaReintentar(intentos: 0, ultimoIntento: t0, ahora: t0), isTrue);
    });

    test('una fila fallida toca solo al cumplirse su espera (inclusive)', () {
      bool toca(Duration despues) => tocaReintentar(
        intentos: 1,
        ultimoIntento: t0,
        ahora: t0.add(despues),
      );
      expect(toca(Duration.zero), isFalse);
      expect(toca(const Duration(seconds: 29)), isFalse);
      expect(toca(const Duration(seconds: 30)), isTrue);
      expect(toca(const Duration(minutes: 5)), isTrue);
    });
  });

  group('SyncEngine con remoto falso y reloj inyectado', () {
    late AppDatabase db;
    late _RemotoFalso remoto;
    late DateTime reloj;
    late SyncEngine motor;

    Future<void> encolar(String tabla, String id) => enqueueSync(
      db,
      tabla: tabla,
      registroId: id,
      operacion: OperacionSync.insert,
      payload: {'campo': id},
    );

    Future<List<SyncQueueData>> cola() => db.select(db.syncQueue).get();

    void avanzar(Duration d) => reloj = reloj.add(d);

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      remoto = _RemotoFalso();
      reloj = DateTime.utc(2026, 1, 1, 12);
      motor = SyncEngine(db: db, remote: remoto, ahora: () => reloj);
    });

    tearDown(() async {
      motor.dispose();
      await db.close();
    });

    test('el éxito sube la fila con user_id y la borra de la cola', () async {
      await encolar('ventas', 'v1');

      await motor.syncNow();

      expect(remoto.intentos, ['mi_negocio_ventas/v1']);
      expect(remoto.filas.single['user_id'], 'usuario-1');
      expect(remoto.filas.single['id'], 'v1');
      expect(await cola(), isEmpty);
    });

    test('una fila que falla NO se reintenta antes de su espera y SÍ '
        'después', () async {
      remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
      await encolar('venta_pagos', 'p1');

      await motor.syncNow(); // intento 1 (falla)
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 1);

      avanzar(const Duration(seconds: 29));
      await motor.syncNow(); // aún en espera (30 s)
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 1);

      avanzar(const Duration(seconds: 1)); // 30 s exactos
      await motor.syncNow(); // toca: intento 2 (falla)
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 2);

      // Tras el 2º fallo la espera es de 60 s.
      avanzar(const Duration(seconds: 59));
      await motor.syncNow();
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 2);
      avanzar(const Duration(seconds: 1));
      await motor.syncNow();
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 3);
    });

    test(
      'al fallar se incrementa intentos y se actualiza updatedAt a ahora',
      () async {
        remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
        await encolar('venta_pagos', 'p1');

        await motor.syncNow();
        var fila = (await cola()).single;
        expect(fila.intentos, 1);
        expect(fila.updatedAt.toUtc(), reloj);

        avanzar(const Duration(seconds: 45));
        await motor.syncNow();
        fila = (await cola()).single;
        expect(fila.intentos, 2);
        expect(fila.updatedAt.toUtc(), reloj);
      },
    );

    test('una fila nueva se intenta aunque haya fallidas en espera', () async {
      remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
      await encolar('venta_pagos', 'p1');
      await motor.syncNow();
      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 1);

      await encolar('ventas', 'v2'); // nueva, sin intentos
      avanzar(const Duration(seconds: 5)); // la fallida sigue en espera
      await motor.syncNow();

      expect(remoto.intentosDe('mi_negocio_venta_pagos'), 1);
      expect(remoto.intentosDe('mi_negocio_ventas'), 1);
      // La nueva se subió y salió de la cola; la fallida sigue.
      final restantes = await cola();
      expect(restantes.map((f) => f.tabla), ['venta_pagos']);
    });

    test('una fila que falla no impide subir las demás', () async {
      remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
      await encolar('venta_pagos', 'p1'); // primera y fallida
      await encolar('ventas', 'v1');
      await encolar('venta_items', 'i1');

      await motor.syncNow();

      expect(
        remoto.intentos,
        containsAll([
          'mi_negocio_venta_pagos/p1',
          'mi_negocio_ventas/v1',
          'mi_negocio_venta_items/i1',
        ]),
      );
      expect((await cola()).map((f) => f.tabla), ['venta_pagos']);
    });

    test('NUNCA se descarta una fila: tras muchos fallos sigue pendiente y, '
        'al recuperarse el servidor, sube y se borra', () async {
      remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
      await encolar('venta_pagos', 'p1');

      for (var i = 0; i < 15; i++) {
        avanzar(const Duration(hours: 7)); // siempre supera la espera máxima
        await motor.syncNow();
      }
      var fila = (await cola()).single;
      expect(fila.intentos, 15);
      expect(fila.estado, EstadoSync.pendiente);

      // El propietario aplica la migración: el servidor ya la acepta.
      remoto.tablasQueFallan.clear();
      avanzar(const Duration(hours: 7));
      await motor.syncNow();
      expect(await cola(), isEmpty);
    });

    test('sin sesión (user_id nulo) no intenta nada', () async {
      remoto.userId = null;
      await encolar('ventas', 'v1');

      await motor.syncNow();

      expect(remoto.intentos, isEmpty);
      expect(await cola(), hasLength(1));
    });

    test('con miles de filas fallidas en espera, una pasada no hace '
        'ninguna petición', () async {
      remoto.tablasQueFallan.add('mi_negocio_venta_pagos');
      for (var i = 0; i < 50; i++) {
        await encolar('venta_pagos', 'p$i');
      }
      await motor.syncNow();
      expect(remoto.intentos, hasLength(50)); // primera pasada: todas nuevas

      avanzar(const Duration(seconds: 10));
      await motor.syncNow();
      await motor.syncNow();

      expect(remoto.intentos, hasLength(50)); // ninguna petición más
    });
  });
}
