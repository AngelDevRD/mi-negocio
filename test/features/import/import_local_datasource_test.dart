import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/features/import/data/datasources/import_local_datasource.dart';
import 'package:app_gestion/features/import/domain/entities/import_target.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ImportLocalDatasource datasource;
  late String usuarioId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = ImportLocalDatasource(db);

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
  });

  tearDown(() async {
    await db.close();
  });

  group('transformarFila', () {
    ColumnMapping mapeo(
      String campo, {
      required ColumnTransform transform,
      Map<String, String>? enumValores,
    }) {
      return ColumnMapping(
        campo: campo,
        columna: campo,
        transform: transform,
        enumValores: enumValores,
      );
    }

    test('transforma texto, numero y dinero', () {
      final encabezados = ['nombre', 'cantidad', 'precio'];
      final fila = ['Coca Cola', '12.5', '1,250.50'];
      final resultado = datasource.transformarFila(fila, encabezados, {
        'nombre': mapeo('nombre', transform: ColumnTransform.texto),
        'cantidad': mapeo('cantidad', transform: ColumnTransform.numero),
        'precio': mapeo('precio', transform: ColumnTransform.dinero),
      });

      expect(resultado['nombre'], 'Coca Cola');
      expect(resultado['cantidad'], 12.5);
      expect(resultado['precio'], 125050);
    });

    test('transforma fechas en formato ISO, dd/mm/yyyy y serie de Excel', () {
      final encabezados = ['iso', 'corta', 'serie'];
      final fila = ['2026-01-15T00:00:00Z', '05/02/2026', '44927'];
      final resultado = datasource.transformarFila(fila, encabezados, {
        'iso': mapeo('iso', transform: ColumnTransform.fecha),
        'corta': mapeo('corta', transform: ColumnTransform.fecha),
        'serie': mapeo('serie', transform: ColumnTransform.fecha),
      });

      expect(resultado['iso'], DateTime.utc(2026, 1, 15));
      expect(resultado['corta'], DateTime.utc(2026, 2, 5));
      expect(resultado['serie'], DateTime.utc(2023, 1, 1));
    });

    test('transforma valores enumerados y sí/no', () {
      final encabezados = ['tipo', 'activo'];
      final fila = ['Vendedor', 'Sí'];
      final resultado = datasource.transformarFila(fila, encabezados, {
        'tipo': mapeo(
          'tipo',
          transform: ColumnTransform.enumerado,
          enumValores: {'Vendedor': 'ventas', 'Repartidor': 'delivery'},
        ),
        'activo': mapeo('activo', transform: ColumnTransform.siNo),
      });

      expect(resultado['tipo'], 'ventas');
      expect(resultado['activo'], true);
    });

    test('columnas sin valor o sin mapeo dan null', () {
      final encabezados = ['nombre', 'precio'];
      final fila = ['Pan', ''];
      final resultado = datasource.transformarFila(fila, encabezados, {
        'nombre': mapeo('nombre', transform: ColumnTransform.texto),
        'precio': mapeo('precio', transform: ColumnTransform.dinero),
        'inexistente': ColumnMapping(
          campo: 'inexistente',
          columna: null,
          transform: ColumnTransform.texto,
        ),
      });

      expect(resultado['precio'], isNull);
      expect(resultado['inexistente'], isNull);
    });
  });

  group('importarProductos', () {
    test('crea la categoría si no existe e inserta el producto', () async {
      final encabezados = [
        'nombre',
        'categoria',
        'precioCompra',
        'precioVenta',
      ];
      final filas = [
        ['Coca Cola', 'Bebidas', '40.00', '50.00'],
      ];
      final mapeo = {
        for (final campo in camposImportacion[ImportTargetType.productos]!)
          campo.campo: ColumnMapping(
            campo: campo.campo,
            columna: encabezados.contains(campo.campo) ? campo.campo : null,
            transform: campo.transform,
          ),
      };

      final resultado = await datasource.importarProductos(
        encabezados: encabezados,
        filas: filas,
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      expect(resultado.insertados, 1);
      expect(resultado.errores, isEmpty);

      final productos = await db.select(db.productos).get();
      expect(productos, hasLength(1));
      expect(productos.single.nombre, 'Coca Cola');
      expect(productos.single.precioCompra, 4000);
      expect(productos.single.precioVenta, 5000);
      expect(productos.single.unidad, 'unidad');

      final categorias = await db.select(db.categorias).get();
      expect(categorias.single.nombre, 'Bebidas');
      expect(productos.single.categoriaId, categorias.single.id);
    });

    test('reporta error si falta el nombre', () async {
      final encabezados = ['nombre'];
      final filas = [
        [''],
      ];
      final mapeo = {
        'nombre': ColumnMapping(
          campo: 'nombre',
          columna: 'nombre',
          transform: ColumnTransform.texto,
        ),
      };

      final resultado = await datasource.importarProductos(
        encabezados: encabezados,
        filas: filas,
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      expect(resultado.insertados, 0);
      expect(resultado.errores, hasLength(1));
      expect(resultado.errores.single, contains('Fila 2'));
    });
  });

  group('importarGastos', () {
    test('inserta el gasto con cajaSesionId null', () async {
      final encabezados = ['categoria', 'concepto', 'fecha', 'monto'];
      final filas = [
        ['Luz', 'Factura de luz', '2026-01-10', '500.00'],
      ];
      final mapeo = {
        'categoria': ColumnMapping(
          campo: 'categoria',
          columna: 'categoria',
          transform: ColumnTransform.texto,
        ),
        'concepto': ColumnMapping(
          campo: 'concepto',
          columna: 'concepto',
          transform: ColumnTransform.texto,
        ),
        'fecha': ColumnMapping(
          campo: 'fecha',
          columna: 'fecha',
          transform: ColumnTransform.fecha,
        ),
        'monto': ColumnMapping(
          campo: 'monto',
          columna: 'monto',
          transform: ColumnTransform.dinero,
        ),
      };

      final resultado = await datasource.importarGastos(
        encabezados: encabezados,
        filas: filas,
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      expect(resultado.insertados, 1);
      expect(resultado.errores, isEmpty);

      final gastos = await db.select(db.gastos).get();
      expect(gastos.single.categoria, 'Luz');
      expect(gastos.single.monto, 50000);
      expect(gastos.single.cajaSesionId, isNull);
    });

    test('reporta error si faltan datos obligatorios', () async {
      final encabezados = ['categoria', 'concepto', 'fecha', 'monto'];
      final filas = [
        ['Luz', '', '2026-01-10', '500.00'],
      ];
      final mapeo = {
        'categoria': ColumnMapping(
          campo: 'categoria',
          columna: 'categoria',
          transform: ColumnTransform.texto,
        ),
        'concepto': ColumnMapping(
          campo: 'concepto',
          columna: 'concepto',
          transform: ColumnTransform.texto,
        ),
        'fecha': ColumnMapping(
          campo: 'fecha',
          columna: 'fecha',
          transform: ColumnTransform.fecha,
        ),
        'monto': ColumnMapping(
          campo: 'monto',
          columna: 'monto',
          transform: ColumnTransform.dinero,
        ),
      };

      final resultado = await datasource.importarGastos(
        encabezados: encabezados,
        filas: filas,
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      expect(resultado.insertados, 0);
      expect(resultado.errores, hasLength(1));
    });
  });

  group('importarEmpleados', () {
    test('mapea el tipo a TipoEmpleado, con ventas por defecto', () async {
      final encabezados = ['tipo', 'nombre', 'fechaIngreso'];
      final filas = [
        ['delivery', 'Pedro', '2026-01-01'],
        ['', 'Juan', '2026-01-02'],
      ];
      final mapeo = {
        'tipo': ColumnMapping(
          campo: 'tipo',
          columna: 'tipo',
          transform: ColumnTransform.texto,
        ),
        'nombre': ColumnMapping(
          campo: 'nombre',
          columna: 'nombre',
          transform: ColumnTransform.texto,
        ),
        'fechaIngreso': ColumnMapping(
          campo: 'fechaIngreso',
          columna: 'fechaIngreso',
          transform: ColumnTransform.fecha,
        ),
      };

      final resultado = await datasource.importarEmpleados(
        encabezados: encabezados,
        filas: filas,
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      expect(resultado.insertados, 2);
      final empleados = await (db.select(
        db.empleados,
      )..orderBy([(t) => OrderingTerm(expression: t.nombre)])).get();
      expect(empleados.map((e) => e.nombre), ['Juan', 'Pedro']);
      expect(
        empleados.firstWhere((e) => e.nombre == 'Pedro').tipo,
        TipoEmpleado.delivery,
      );
      expect(
        empleados.firstWhere((e) => e.nombre == 'Juan').tipo,
        TipoEmpleado.ventas,
      );
    });
  });

  group('importarCompras', () {
    test(
      'crea producto y proveedor, inserta compra+item sin afectar stock',
      () async {
        final encabezados = [
          'proveedor',
          'producto',
          'cantidad',
          'costoUnitario',
          'fecha',
        ];
        final filas = [
          ['Distribuidora ABC', 'Arroz', '10', '30.00', '2026-01-05'],
        ];
        final mapeo = {
          'proveedor': ColumnMapping(
            campo: 'proveedor',
            columna: 'proveedor',
            transform: ColumnTransform.texto,
          ),
          'producto': ColumnMapping(
            campo: 'producto',
            columna: 'producto',
            transform: ColumnTransform.texto,
          ),
          'cantidad': ColumnMapping(
            campo: 'cantidad',
            columna: 'cantidad',
            transform: ColumnTransform.numero,
          ),
          'costoUnitario': ColumnMapping(
            campo: 'costoUnitario',
            columna: 'costoUnitario',
            transform: ColumnTransform.dinero,
          ),
          'numeroFactura': ColumnMapping(
            campo: 'numeroFactura',
            columna: null,
            transform: ColumnTransform.texto,
          ),
          'fecha': ColumnMapping(
            campo: 'fecha',
            columna: 'fecha',
            transform: ColumnTransform.fecha,
          ),
        };

        final resultado = await datasource.importarCompras(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        );

        expect(resultado.insertados, 1);
        expect(resultado.errores, isEmpty);

        final productos = await db.select(db.productos).get();
        expect(productos.single.nombre, 'Arroz');
        expect(productos.single.stockActual, 0);

        final proveedores = await db.select(db.proveedores).get();
        expect(proveedores.single.nombre, 'Distribuidora ABC');

        final compras = await db.select(db.compras).get();
        expect(compras.single.total, 30000);
        expect(compras.single.proveedorId, proveedores.single.id);

        final items = await db.select(db.compraItems).get();
        expect(items.single.productoId, productos.single.id);
        expect(items.single.costoUnitario, 3000);

        final auditoria =
            await (db.select(db.auditoria)..where(
                  (t) =>
                      t.modulo.equals('compras') & t.accion.equals('importar'),
                ))
                .get();
        expect(auditoria, hasLength(1));
      },
    );
  });

  group('importarVentas', () {
    test(
      'crea producto, sesión de caja sintética e inserta venta+item',
      () async {
        final encabezados = [
          'producto',
          'cantidad',
          'precioUnitario',
          'costoUnitario',
          'fecha',
        ];
        final filas = [
          ['Arroz', '2', '50.00', '30.00', '2026-01-06'],
          ['Arroz', '1', '50.00', '30.00', '2026-01-07'],
        ];
        final mapeo = {
          'producto': ColumnMapping(
            campo: 'producto',
            columna: 'producto',
            transform: ColumnTransform.texto,
          ),
          'cantidad': ColumnMapping(
            campo: 'cantidad',
            columna: 'cantidad',
            transform: ColumnTransform.numero,
          ),
          'precioUnitario': ColumnMapping(
            campo: 'precioUnitario',
            columna: 'precioUnitario',
            transform: ColumnTransform.dinero,
          ),
          'costoUnitario': ColumnMapping(
            campo: 'costoUnitario',
            columna: 'costoUnitario',
            transform: ColumnTransform.dinero,
          ),
          'fecha': ColumnMapping(
            campo: 'fecha',
            columna: 'fecha',
            transform: ColumnTransform.fecha,
          ),
        };

        final resultado = await datasource.importarVentas(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        );

        expect(resultado.insertados, 2);
        expect(resultado.errores, isEmpty);

        final ventas = await db.select(db.ventas).get();
        expect(ventas, hasLength(2));
        expect(ventas.every((v) => v.nota == 'Importado'), isTrue);

        // Ambas ventas reutilizan la misma sesión de caja sintética.
        final sesiones = ventas.map((v) => v.cajaSesionId).toSet();
        expect(sesiones, hasLength(1));

        final cajaSesiones = await db.select(db.cajaSesiones).get();
        expect(cajaSesiones, hasLength(1));
        expect(cajaSesiones.single.estado, EstadoCajaSesion.cerrada);

        final productos = await db.select(db.productos).get();
        expect(productos.single.stockActual, 0);

        final primeraVenta = ventas.firstWhere((v) => v.total == 10000);
        expect(primeraVenta.ganancia, 4000);
      },
    );

    test('reutiliza la sesión de caja sintética entre llamadas', () async {
      final encabezados = [
        'producto',
        'cantidad',
        'precioUnitario',
        'costoUnitario',
        'fecha',
      ];
      final mapeo = {
        'producto': ColumnMapping(
          campo: 'producto',
          columna: 'producto',
          transform: ColumnTransform.texto,
        ),
        'cantidad': ColumnMapping(
          campo: 'cantidad',
          columna: 'cantidad',
          transform: ColumnTransform.numero,
        ),
        'precioUnitario': ColumnMapping(
          campo: 'precioUnitario',
          columna: 'precioUnitario',
          transform: ColumnTransform.dinero,
        ),
        'costoUnitario': ColumnMapping(
          campo: 'costoUnitario',
          columna: 'costoUnitario',
          transform: ColumnTransform.dinero,
        ),
        'fecha': ColumnMapping(
          campo: 'fecha',
          columna: 'fecha',
          transform: ColumnTransform.fecha,
        ),
      };

      await datasource.importarVentas(
        encabezados: encabezados,
        filas: [
          ['Arroz', '1', '50.00', '30.00', '2026-01-06'],
        ],
        mapeo: mapeo,
        usuarioId: usuarioId,
      );
      await datasource.importarVentas(
        encabezados: encabezados,
        filas: [
          ['Arroz', '1', '50.00', '30.00', '2026-01-07'],
        ],
        mapeo: mapeo,
        usuarioId: usuarioId,
      );

      final cajaSesiones = await db.select(db.cajaSesiones).get();
      expect(cajaSesiones, hasLength(1));
    });
  });
}
