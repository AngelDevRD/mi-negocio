import 'dart:convert';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/dashboard/data/datasources/dashboard_dao.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Datasource de prueba: fuerza el camino de traducción de
/// [ProductoInexistenteException] en [SalesRepositoryImpl.registrarVenta]
/// sin depender de una carrera real (existeProducto/obtenerCajaAbiertaId
/// siguen siendo los reales, heredados, para que el resto del flujo del
/// repositorio no cambie).
class _DatasourceQueLanzaProductoInexistente extends SalesLocalDatasource {
  _DatasourceQueLanzaProductoInexistente(super.db, this.productoId);

  final String productoId;

  @override
  Future<String> registrarVenta({
    required TipoVenta tipo,
    required List<VentaItemEntrada> items,
    String? nota,
    required String cajaSesionId,
    required String usuarioId,
    required bool permitirStockNegativo,
    MetodoPago metodoPago = MetodoPago.efectivo,
  }) {
    throw ProductoInexistenteException(productoId);
  }
}

void main() {
  late AppDatabase db;
  late SalesLocalDatasource local;
  late SettingsLocalDatasource settings;
  late SalesRepositoryImpl repo;
  late String usuarioId;
  late String productoId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = SalesLocalDatasource(db);
    settings = SettingsLocalDatasource(db);
    repo = SalesRepositoryImpl(local, settings);

    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Negocio Test',
          ),
        );

    usuarioId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(usuarioId),
            negocioId: negocioId,
            nombre: 'Admin',
            username: 'admin',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );

    productoId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoId),
            nombre: 'Salami',
            unidad: const Value('libra'),
            precioCompra: const Value(100),
            precioVenta: const Value(150),
            stockActual: const Value(10),
            stockMinimo: const Value(2),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('abrirCaja', () {
    test('abre una sesión de caja', () async {
      final result = await repo.abrirCaja(
        montoApertura: const Money(50000),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isTrue);

      final sesiones = await db.select(db.cajaSesiones).get();
      expect(sesiones, hasLength(1));
      expect(sesiones.single.estado, EstadoCajaSesion.abierta);
      expect(sesiones.single.montoApertura, 50000);
    });

    test('falla con monto negativo', () async {
      final result = await repo.abrirCaja(
        montoApertura: const Money(-100),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si ya hay una sesión abierta', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      final result = await repo.abrirCaja(
        montoApertura: const Money(0),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'RN-01: dos aperturas concurrentes solo crean una sesión abierta',
      () async {
        // Dos llamadas concurrentes sin await intercalado (TOCTOU real).
        await Future.wait([
          repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId),
          repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId),
        ]);

        final abiertas = await (db.select(
          db.cajaSesiones,
        )..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta))).get();
        expect(abiertas, hasLength(1));
      },
    );

    test(
      'tolera dos sesiones abiertas preexistentes sin lanzar excepción '
      '(dato corrupto de una instalación previa al fix de RN-01)',
      () async {
        // Insertadas directamente en la base: simulan un estado ya corrupto
        // (p.ej. por el bug de doble apertura de una versión anterior),
        // sin pasar por abrirCaja().
        final antigua = generateUuidV4();
        await db
            .into(db.cajaSesiones)
            .insert(
              CajaSesionesCompanion.insert(
                id: Value(antigua),
                fechaApertura: DateTime.utc(2026, 1, 1),
                montoApertura: 0,
                usuarioApertura: usuarioId,
                estado: EstadoCajaSesion.abierta,
              ),
            );
        final reciente = generateUuidV4();
        await db
            .into(db.cajaSesiones)
            .insert(
              CajaSesionesCompanion.insert(
                id: Value(reciente),
                fechaApertura: DateTime.utc(2026, 6, 1),
                montoApertura: 0,
                usuarioApertura: usuarioId,
                estado: EstadoCajaSesion.abierta,
              ),
            );

        final id = await local.obtenerCajaAbiertaId();
        expect(id, reciente);

        final result = await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        expect(result.isOk, isFalse);
        result.when(
          ok: (_) => fail('no debería tener éxito'),
          fail: (f) {
            expect(f, isA<ValidationFailure>());
            expect(f.message, 'Ya existe una sesión de caja abierta.');
          },
        );
      },
    );
  });

  group('registrarVenta', () {
    test('falla si no hay items', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: const [],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si la cantidad de un ítem es cero o negativa', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 0,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el precio de un ítem es negativo', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(-10),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si el producto no existe', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: generateUuidV4(),
            productoNombre: 'Inexistente',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test('falla si no hay caja abierta (RN-01)', () async {
      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) {
          expect(f, isA<BusinessRuleFailure>());
          expect((f as BusinessRuleFailure).rule, 'RN-01');
        },
      );
    });

    test(
      'venta completa calcula ganancia, descuenta stock y registra caja/auditoría',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );

        final result = await repo.registrarVenta(
          tipo: TipoVenta.detallada,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 4,
              precioUnitario: const Money(150),
            ),
          ],
          nota: 'Cliente frecuente',
          usuarioId: usuarioId,
        );
        expect(result.isOk, isTrue);
        final ventaId = result.valueOrNull!;

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 6);

        final venta = await repo.obtenerVenta(ventaId);
        expect(venta, isNotNull);
        expect(venta!.total, const Money(600));
        expect(venta.ganancia, const Money(200));
        expect(venta.estado, EstadoVenta.completada);
        expect(venta.nota, 'Cliente frecuente');
        expect(venta.items, hasLength(1));
        expect(venta.items.single.costoUnitario, const Money(100));

        final movimientos = await db.select(db.movimientosInventario).get();
        expect(movimientos, hasLength(1));
        expect(movimientos.single.tipo, TipoMovimientoInventario.venta);
        expect(movimientos.single.cantidad, -4);

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, hasLength(1));
        expect(movimientosCaja.single.tipo, TipoCajaMovimiento.venta);
        expect(movimientosCaja.single.monto, 600);

        final auditoria = await db.select(db.auditoria).get();
        // Apertura de caja + entrada de inventario (applyMovement) + ventas.
        expect(auditoria, hasLength(3));
        expect(
          auditoria.map((a) => a.modulo),
          containsAll(<String>['caja', 'inventario', 'ventas']),
        );
      },
    );

    test(
      'RN-05: aborta toda la venta (sin rastro) si un producto ya no existe '
      'al momento de escribir la transacción',
      () async {
        // Reproduce la condición de carrera real: el repositorio ya validó
        // con existeProducto() (que SalesRepositoryImpl.registrarVenta hace
        // antes de llamar al datasource), pero el producto se elimina antes
        // de que la transacción lea su costo. Se llama al datasource
        // directamente porque el pre-chequeo del repositorio, correcto para
        // el caso normal, no puede detectar un borrado ocurrido después.
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        final cajaSesionId = (await local.obtenerCajaAbiertaId())!;

        await expectLater(
          local.registrarVenta(
            tipo: TipoVenta.rapida,
            items: [
              VentaItemEntrada(
                productoId: productoId,
                cantidad: 2,
                precioUnitarioCents: 15000,
              ),
              VentaItemEntrada(
                productoId: generateUuidV4(), // eliminado justo antes.
                cantidad: 1,
                precioUnitarioCents: 5000,
              ),
            ],
            cajaSesionId: cajaSesionId,
            usuarioId: usuarioId,
            permitirStockNegativo: true,
          ),
          throwsA(isA<ProductoInexistenteException>()),
        );

        final ventas = await db.select(db.ventas).get();
        expect(ventas, isEmpty);
        final ventaItems = await db.select(db.ventaItems).get();
        expect(ventaItems, isEmpty);
        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, isEmpty);
        final movimientosInventario = await db
            .select(db.movimientosInventario)
            .get();
        expect(movimientosInventario, isEmpty);

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 10);
      },
    );

    test(
      'RN-05: traduce ProductoInexistenteException a ValidationFailure con '
      'el nombre del producto',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        final repoConDatasourceQueLanza = SalesRepositoryImpl(
          _DatasourceQueLanzaProductoInexistente(db, productoId),
          settings,
        );

        final result = await repoConDatasourceQueLanza.registrarVenta(
          tipo: TipoVenta.rapida,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 1,
              precioUnitario: const Money(150),
            ),
          ],
          usuarioId: usuarioId,
        );

        expect(result.isOk, isFalse);
        result.when(
          ok: (_) => fail('no debería tener éxito'),
          fail: (f) {
            expect(f, isA<ValidationFailure>());
            expect(
              f.message,
              'El producto "Salami" no existe o fue eliminado.',
            );
          },
        );
      },
    );
  });

  group('anularVenta', () {
    test('falla si la venta no existe', () async {
      final result = await repo.anularVenta(
        generateUuidV4(),
        usuarioId: usuarioId,
      );
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'revierte stock, registra salida de caja y marca como anulada',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        final registro = await repo.registrarVenta(
          tipo: TipoVenta.rapida,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 4,
              precioUnitario: const Money(150),
            ),
          ],
          usuarioId: usuarioId,
        );
        final ventaId = registro.valueOrNull!;

        final result = await repo.anularVenta(ventaId, usuarioId: usuarioId);
        expect(result.isOk, isTrue);

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        expect(producto.stockActual, 10);

        final venta = await repo.obtenerVenta(ventaId);
        expect(venta!.estado, EstadoVenta.anulada);

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        expect(movimientosCaja, hasLength(2));
        expect(
          movimientosCaja.map((m) => m.monto),
          containsAll(<int>[600, -600]),
        );
      },
    );

    test('falla si la venta ya está anulada', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      final registro = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 1,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );
      final ventaId = registro.valueOrNull!;
      await repo.anularVenta(ventaId, usuarioId: usuarioId);

      final result = await repo.anularVenta(ventaId, usuarioId: usuarioId);
      expect(result.isOk, isFalse);
      result.when(
        ok: (_) => fail('no debería tener éxito'),
        fail: (f) => expect(f, isA<ValidationFailure>()),
      );
    });

    test(
      'RN-10: dos anulaciones concurrentes solo revierten el stock una vez',
      () async {
        await repo.abrirCaja(
          montoApertura: const Money(0),
          usuarioId: usuarioId,
        );
        final registro = await repo.registrarVenta(
          tipo: TipoVenta.rapida,
          items: [
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 4,
              precioUnitario: const Money(150),
            ),
          ],
          usuarioId: usuarioId,
        );
        final ventaId = registro.valueOrNull!;

        // Dos llamadas concurrentes sin await intercalado (TOCTOU real).
        await Future.wait([
          repo.anularVenta(ventaId, usuarioId: usuarioId),
          repo.anularVenta(ventaId, usuarioId: usuarioId),
        ]);

        final producto = await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle();
        // Stock inicial 10 - 4 vendidas + 4 revertidas UNA sola vez = 10.
        expect(producto.stockActual, 10);

        final movimientosInventario = await (db.select(
          db.movimientosInventario,
        )..where((t) => t.tipo.equalsValue(TipoMovimientoInventario.anulacionVenta))).get();
        expect(movimientosInventario, hasLength(1));

        final movimientosCaja = await db.select(db.cajaMovimientos).get();
        final movimientosCajaAnulacion = movimientosCaja
            .where((m) => m.referenciaId == ventaId && m.monto < 0)
            .toList();
        expect(movimientosCajaAnulacion, hasLength(1));
        expect(movimientosCajaAnulacion.single.monto, -600);
      },
    );
  });

  group('RN-12: vender sin stock', () {
    Future<Result<String>> vender(double cantidad) => repo.registrarVenta(
      tipo: TipoVenta.rapida,
      items: [
        ItemVentaInput(
          productoId: productoId,
          productoNombre: 'Salami',
          cantidad: cantidad,
          precioUnitario: const Money(150),
        ),
      ],
      usuarioId: usuarioId,
    );

    Future<double> stock() async =>
        (await (db.select(
          db.productos,
        )..where((t) => t.id.equals(productoId))).getSingle()).stockActual;

    Future<void> verificarNadaEscrito() async {
      expect(await db.select(db.ventas).get(), isEmpty);
      expect(await db.select(db.ventaItems).get(), isEmpty);
      expect(await db.select(db.cajaMovimientos).get(), isEmpty);
      expect(await db.select(db.movimientosInventario).get(), isEmpty);
      expect(await stock(), 10);
    }

    test('por defecto (sin ajuste guardado) se permite y el stock queda '
        'negativo', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);

      final result = await vender(15);

      expect(result.isOk, isTrue);
      expect(await stock(), -5);
    });

    test('con el ajuste en true la venta pasa y el stock queda negativo', () async {
      await settings.establecerPermitirStockNegativo(
        true,
        usuarioId: usuarioId,
      );
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);

      final result = await vender(15);

      expect(result.isOk, isTrue);
      expect(await stock(), -5);
    });

    test('con el ajuste en false y stock insuficiente: Result.fail RN-12 y '
        'NO se escribe nada', () async {
      await settings.establecerPermitirStockNegativo(
        false,
        usuarioId: usuarioId,
      );
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);

      final result = await vender(15);

      result.when(
        ok: (_) => fail('debió fallar por stock insuficiente'),
        fail: (f) {
          expect(f, isA<BusinessRuleFailure>());
          expect((f as BusinessRuleFailure).rule, 'RN-12');
          expect(
            f.message,
            'No hay suficiente stock de "Salami": disponible 10 libras, '
            'solicitado 15 libras.',
          );
        },
      );
      await verificarNadaEscrito();
    });

    test('las líneas del mismo producto se SUMAN (6 + 6 > 10)', () async {
      await settings.establecerPermitirStockNegativo(
        false,
        usuarioId: usuarioId,
      );
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);

      final result = await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          for (var i = 0; i < 2; i++)
            ItemVentaInput(
              productoId: productoId,
              productoNombre: 'Salami',
              cantidad: 6,
              precioUnitario: const Money(150),
            ),
        ],
        usuarioId: usuarioId,
      );

      result.when(
        ok: (_) => fail('debió fallar: 12 > 10 disponibles'),
        fail: (f) {
          expect((f as BusinessRuleFailure).rule, 'RN-12');
          expect(f.message, contains('solicitado 12 libras'));
        },
      );
      await verificarNadaEscrito();
    });

    test('con el ajuste en false, vender EXACTAMENTE lo disponible pasa', () async {
      await settings.establecerPermitirStockNegativo(
        false,
        usuarioId: usuarioId,
      );
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);

      final result = await vender(10);

      expect(result.isOk, isTrue);
      expect(await stock(), 0);
    });

    test('el datasource lanza StockInsuficienteException antes de escribir '
        '(defensa en la transacción)', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      final cajaSesionId = (await local.obtenerCajaAbiertaId())!;

      await expectLater(
        local.registrarVenta(
          tipo: TipoVenta.rapida,
          items: [
            VentaItemEntrada(
              productoId: productoId,
              cantidad: 11,
              precioUnitarioCents: 15000,
            ),
          ],
          cajaSesionId: cajaSesionId,
          usuarioId: usuarioId,
          permitirStockNegativo: false,
        ),
        throwsA(
          isA<StockInsuficienteException>()
              .having((e) => e.disponible, 'disponible', 10)
              .having((e) => e.solicitado, 'solicitado', 11),
        ),
      );
      await verificarNadaEscrito();
    });
  });

  group('método de pago (venta_pagos)', () {
    Future<String> vender({MetodoPago? metodo}) async {
      final result = metodo == null
          ? await repo.registrarVenta(
              tipo: TipoVenta.rapida,
              items: [
                ItemVentaInput(
                  productoId: productoId,
                  productoNombre: 'Salami',
                  cantidad: 2,
                  precioUnitario: const Money(150),
                ),
              ],
              usuarioId: usuarioId,
            )
          : await repo.registrarVenta(
              tipo: TipoVenta.rapida,
              items: [
                ItemVentaInput(
                  productoId: productoId,
                  productoNombre: 'Salami',
                  cantidad: 2,
                  precioUnitario: const Money(150),
                ),
              ],
              usuarioId: usuarioId,
              metodoPago: metodo,
            );
      return result.valueOrNull!;
    }

    Future<int> montoActualDeCaja() async {
      final caja = await DashboardDao(db).watchCajaActual().first;
      return caja!.montoActual.cents;
    }

    setUp(() async {
      await repo.abrirCaja(
        montoApertura: const Money(1000),
        usuarioId: usuarioId,
      );
    });

    test('efectivo (y el valor por defecto): crea venta_pagos efectivo Y el '
        'movimiento de caja', () async {
      final ventaId = await vender();

      final pagos = await db.select(db.ventaPagos).get();
      expect(pagos, hasLength(1));
      expect(pagos.single.ventaId, ventaId);
      expect(pagos.single.metodo, MetodoPago.efectivo);
      expect(pagos.single.monto, 300);

      final movimientos = await db.select(db.cajaMovimientos).get();
      expect(movimientos.where((m) => m.referenciaId == ventaId), hasLength(1));
      expect(await montoActualDeCaja(), 1000 + 300);
    });

    test('tarjeta: crea venta_pagos tarjeta y NINGÚN movimiento de caja', () async {
      final ventaId = await vender(metodo: MetodoPago.tarjeta);

      final pagos = await db.select(db.ventaPagos).get();
      expect(pagos.single.metodo, MetodoPago.tarjeta);
      expect(pagos.single.monto, 300);

      final movimientos = await db.select(db.cajaMovimientos).get();
      expect(movimientos.where((m) => m.referenciaId == ventaId), isEmpty);
      // La venta sí existe y descontó stock.
      expect(await db.select(db.ventas).get(), hasLength(1));
      final producto = await (db.select(
        db.productos,
      )..where((t) => t.id.equals(productoId))).getSingle();
      expect(producto.stockActual, 8);
    });

    test('el monto de la caja SOLO sube con efectivo', () async {
      expect(await montoActualDeCaja(), 1000);

      await vender(metodo: MetodoPago.tarjeta);
      await vender(metodo: MetodoPago.transferencia);
      expect(await montoActualDeCaja(), 1000);

      await vender(metodo: MetodoPago.efectivo);
      expect(await montoActualDeCaja(), 1000 + 300);
    });

    test('anular una venta con tarjeta NO crea movimiento de caja', () async {
      final ventaId = await vender(metodo: MetodoPago.tarjeta);

      final result = await repo.anularVenta(ventaId, usuarioId: usuarioId);

      expect(result.isOk, isTrue);
      expect(await db.select(db.cajaMovimientos).get(), isEmpty);
      expect(await montoActualDeCaja(), 1000);
      // El stock sí se revierte.
      final producto = await (db.select(
        db.productos,
      )..where((t) => t.id.equals(productoId))).getSingle();
      expect(producto.stockActual, 10);
    });

    test('anular una venta en efectivo SÍ crea el movimiento compensatorio', () async {
      final ventaId = await vender(metodo: MetodoPago.efectivo);
      expect(await montoActualDeCaja(), 1300);

      await repo.anularVenta(ventaId, usuarioId: usuarioId);

      final movimientos = await db.select(db.cajaMovimientos).get();
      expect(
        movimientos.where((m) => m.referenciaId == ventaId).map((m) => m.monto),
        unorderedEquals([300, -300]),
      );
      expect(await montoActualDeCaja(), 1000);
    });

    test('una venta histórica SIN venta_pagos se lee como efectivo por el '
        'total (detalle y anulación)', () async {
      // Venta "de la v1": sin fila en venta_pagos, con su movimiento de caja.
      final sesionId = (await local.obtenerCajaAbiertaId())!;
      final ventaId = generateUuidV4();
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              id: Value(ventaId),
              tipo: TipoVenta.rapida,
              total: 500,
              ganancia: 100,
              cajaSesionId: sesionId,
              usuarioId: usuarioId,
              estado: EstadoVenta.completada,
              fecha: DateTime.now().toUtc(),
            ),
          );
      await db
          .into(db.ventaItems)
          .insert(
            VentaItemsCompanion.insert(
              ventaId: ventaId,
              productoId: productoId,
              cantidad: 1,
              precioUnitario: 500,
              costoUnitario: 400,
            ),
          );
      await db
          .into(db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: sesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: 500,
              referenciaId: Value(ventaId),
              usuarioId: usuarioId,
            ),
          );
      expect(await db.select(db.ventaPagos).get(), isEmpty);

      final detalle = await repo.obtenerVenta(ventaId);
      expect(detalle!.metodoPago, MetodoPago.efectivo);

      await repo.anularVenta(ventaId, usuarioId: usuarioId);
      final movimientos = await db.select(db.cajaMovimientos).get();
      expect(
        movimientos.where((m) => m.referenciaId == ventaId).map((m) => m.monto),
        unorderedEquals([500, -500]),
      );
    });

    test('el detalle devuelve el método de la venta', () async {
      final ventaId = await vender(metodo: MetodoPago.transferencia);

      final detalle = await repo.obtenerVenta(ventaId);

      expect(detalle!.metodoPago, MetodoPago.transferencia);
    });

    test('se encola el sync de venta_pagos con payload en snake_case', () async {
      final ventaId = await vender(metodo: MetodoPago.tarjeta);

      final cola = await (db.select(
        db.syncQueue,
      )..where((t) => t.tabla.equals('venta_pagos'))).get();
      expect(cola, hasLength(1));
      expect(cola.single.operacion, OperacionSync.insert);
      final payload = jsonDecode(cola.single.payload) as Map<String, dynamic>;
      expect(payload['venta_id'], ventaId);
      expect(payload['metodo'], 'tarjeta');
      expect(payload['monto'], 300);
      expect(payload.containsKey('created_at'), isTrue);
      expect(payload.containsKey('updated_at'), isTrue);
    });

    test('el payload de ventas NO cambió (sin campo de método)', () async {
      await vender(metodo: MetodoPago.tarjeta);

      final cola = await (db.select(
        db.syncQueue,
      )..where((t) => t.tabla.equals('ventas'))).get();
      final payload = jsonDecode(cola.first.payload) as Map<String, dynamic>;
      expect(payload.keys, isNot(contains('metodo')));
      expect(payload.keys, isNot(contains('metodo_pago')));
    });
  });

  group('watchVentas / obtenerVenta', () {
    test('lista ventas con usuario e items', () async {
      await repo.abrirCaja(montoApertura: const Money(0), usuarioId: usuarioId);
      await repo.registrarVenta(
        tipo: TipoVenta.rapida,
        items: [
          ItemVentaInput(
            productoId: productoId,
            productoNombre: 'Salami',
            cantidad: 2,
            precioUnitario: const Money(150),
          ),
        ],
        usuarioId: usuarioId,
      );

      final lista = await repo.watchVentas().first;
      expect(lista, hasLength(1));
      expect(lista.single.usuarioNombre, 'Admin');
      expect(lista.single.total, const Money(300));
    });

    test('retorna null si la venta no existe', () async {
      final detalle = await repo.obtenerVenta(generateUuidV4());
      expect(detalle, isNull);
    });
  });
}
