import 'package:app_gestion/core/database/app_database.dart'
    hide Venta, VentaItem;
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:drift/drift.dart' show QueryExecutor, QueryInterceptor, Value;
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

/// Cuenta y guarda las consultas SELECT que llegan a la base.
class _ContadorDeConsultas extends QueryInterceptor {
  final sentencias = <String>[];

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    sentencias.add(statement);
    return executor.runSelect(statement, args);
  }
}

void main() {
  late _ContadorDeConsultas consultas;
  late FiadoFixture f;

  setUp(() async {
    consultas = _ContadorDeConsultas();
    f = await FiadoFixture.crear(interceptor: consultas);
    await f.abrirCaja();
  });

  tearDown(() => f.cerrar());

  Future<List<Venta>> lista() => f.ventas.watchVentas().first;

  group('watchVentas trae el método de pago', () {
    test('cada venta llega con su método (efectivo, tarjeta, transferencia y '
        'fiado)', () async {
      final cliente = await f.nuevoCliente();
      final efectivo = (await f.vender()).valueOrNull!;
      final tarjeta = (await f.vender(metodo: MetodoPago.tarjeta)).valueOrNull!;
      final transferencia = (await f.vender(
        metodo: MetodoPago.transferencia,
      )).valueOrNull!;
      final fiado = (await f.vender(
        metodo: MetodoPago.credito,
        clienteId: cliente,
      )).valueOrNull!;

      final ventas = {for (final v in await lista()) v.id: v};

      expect(ventas[efectivo]!.metodoPago, MetodoPago.efectivo);
      expect(ventas[tarjeta]!.metodoPago, MetodoPago.tarjeta);
      expect(ventas[transferencia]!.metodoPago, MetodoPago.transferencia);
      expect(ventas[fiado]!.metodoPago, MetodoPago.credito);
      expect(ventas.values.every((v) => !v.pagoMixto), isTrue);
    });

    test('una venta histórica SIN venta_pagos cuenta como efectivo', () async {
      final sesion = await f.db.select(f.db.cajaSesiones).getSingle();
      await f.db
          .into(f.db.ventas)
          .insert(
            VentasCompanion.insert(
              id: const Value('historica'),
              tipo: TipoVenta.rapida,
              total: 7000,
              ganancia: 0,
              cajaSesionId: sesion.id,
              usuarioId: f.usuarioId,
              estado: EstadoVenta.completada,
              fecha: DateTime.now().toUtc(),
            ),
          );
      expect(await f.cantidadEn('venta_pagos'), 0);

      final venta = (await lista()).single;

      expect(venta.metodoPago, MetodoPago.efectivo);
    });

    test(
      'varios métodos distintos en una venta = "mixto" (sin método)',
      () async {
        final id = (await f.vender()).valueOrNull!; // 30000 en efectivo
        // Se parte el pago: efectivo + tarjeta.
        await f.db
            .into(f.db.ventaPagos)
            .insert(
              VentaPagosCompanion.insert(
                ventaId: id,
                metodo: MetodoPago.tarjeta,
                monto: 10000,
              ),
            );

        final venta = (await lista()).single;

        expect(venta.pagoMixto, isTrue);
        expect(venta.metodoPago, isNull);
      },
    );

    test('dos pagos del MISMO método no son mixtos', () async {
      final id = (await f.vender()).valueOrNull!;
      await f.db
          .into(f.db.ventaPagos)
          .insert(
            VentaPagosCompanion.insert(
              ventaId: id,
              metodo: MetodoPago.efectivo,
              monto: 100,
            ),
          );

      final venta = (await lista()).single;

      expect(venta.pagoMixto, isFalse);
      expect(venta.metodoPago, MetodoPago.efectivo);
    });

    test(
      'el filtro por estado y fecha sigue funcionando con el método',
      () async {
        final ok = (await f.vender(metodo: MetodoPago.tarjeta)).valueOrNull!;
        final anulada = (await f.vender()).valueOrNull!;
        await f.ventas.anularVenta(anulada, usuarioId: f.usuarioId);

        final soloCompletadas = await f.ventas
            .watchVentas(estado: EstadoVenta.completada)
            .first;

        expect(soloCompletadas.map((v) => v.id), [ok]);
        expect(soloCompletadas.single.metodoPago, MetodoPago.tarjeta);
      },
    );
  });

  group('sin consultas N+1', () {
    test('listar 2 o 12 ventas emite las MISMAS consultas y ninguna sobre '
        'venta_pagos por separado', () async {
      for (var i = 0; i < 2; i++) {
        await f.vender(metodo: MetodoPago.tarjeta);
      }
      consultas.sentencias.clear();
      expect(await lista(), hasLength(2));
      final conDos = List<String>.of(consultas.sentencias);

      for (var i = 0; i < 10; i++) {
        await f.vender(
          metodo: i.isEven ? MetodoPago.efectivo : MetodoPago.tarjeta,
        );
      }
      consultas.sentencias.clear();
      final doce = await lista();
      expect(doce, hasLength(12));
      final conDoce = List<String>.of(consultas.sentencias);

      // Mismo número de consultas sin importar cuántas ventas haya...
      expect(conDoce.length, conDos.length);
      // ...y el método sale de esa misma consulta (join), no de una aparte.
      final soloPagos = conDoce.where(
        (s) => s.contains('venta_pagos') && !s.contains('"ventas"'),
      );
      expect(soloPagos, isEmpty);
      expect(
        conDoce.any((s) => s.contains('venta_pagos') && s.contains('"ventas"')),
        isTrue,
      );
      expect(doce.every((v) => v.metodoPago != null), isTrue);
    });
  });
}
