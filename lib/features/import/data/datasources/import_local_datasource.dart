import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/utils/money.dart';
import '../../../employees/data/datasources/employees_local_datasource.dart';
import '../../../expenses/data/datasources/expenses_local_datasource.dart';
import '../../../products/data/datasources/products_local_datasource.dart';
import '../../../purchases/data/datasources/purchases_local_datasource.dart';
import '../../domain/entities/import_target.dart';

/// Aplica el [ColumnMapping] de cada campo e inserta las filas de un Excel
/// de migración en las tablas correspondientes (FASE 20, RF-IMP-03).
///
/// Compras y ventas importadas se insertan directo en `compras`/`ventas` +
/// items, sin pasar por `InventoryLocalDatasource.applyMovement` (RN-03): el
/// stock ya quedó establecido por la importación de productos vía
/// `stockInicial`, así que estos registros son históricos para reportes.
class ImportLocalDatasource {
  ImportLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Transformación de filas
  // ---------------------------------------------------------------------

  /// Aplica [mapeo] a una fila cruda y devuelve un mapa campo -> valor ya
  /// transformado (`String`, `double`, `int` en centavos, `DateTime` UTC o
  /// `bool`, según [ColumnTransform]).
  Map<String, Object?> transformarFila(
    List<String> fila,
    List<String> encabezados,
    Map<String, ColumnMapping> mapeo,
  ) {
    final resultado = <String, Object?>{};
    for (final entry in mapeo.entries) {
      final m = entry.value;
      final columnaIndex = m.columna == null
          ? -1
          : encabezados.indexOf(m.columna!);
      final valorCrudo = (columnaIndex >= 0 && columnaIndex < fila.length)
          ? fila[columnaIndex]
          : '';
      resultado[entry.key] = _transformar(valorCrudo, m);
    }
    return resultado;
  }

  Object? _transformar(String valor, ColumnMapping mapping) {
    final texto = valor.trim();
    if (texto.isEmpty) return null;
    switch (mapping.transform) {
      case ColumnTransform.texto:
        return texto;
      case ColumnTransform.numero:
        return double.tryParse(texto.replaceAll(',', ''));
      case ColumnTransform.dinero:
        try {
          return Money.parse(texto).cents;
        } catch (_) {
          return null;
        }
      case ColumnTransform.fecha:
        return _parseFecha(texto);
      case ColumnTransform.enumerado:
        final enumValores = mapping.enumValores;
        if (enumValores == null) return texto;
        final coincidencia = enumValores.entries.firstWhere(
          (e) => e.key.toLowerCase() == texto.toLowerCase(),
          orElse: () => MapEntry(texto, texto),
        );
        return coincidencia.value;
      case ColumnTransform.siNo:
        final normal = texto.toLowerCase();
        return normal == 'si' ||
            normal == 'sí' ||
            normal == 'true' ||
            normal == '1' ||
            normal == 'yes';
    }
  }

  DateTime? _parseFecha(String texto) {
    final iso = DateTime.tryParse(texto);
    if (iso != null) return iso.toUtc();

    final formatoCorto = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final match = formatoCorto.firstMatch(texto);
    if (match != null) {
      final dia = int.parse(match.group(1)!);
      final mes = int.parse(match.group(2)!);
      var anio = int.parse(match.group(3)!);
      if (anio < 100) anio += 2000;
      try {
        return DateTime.utc(anio, mes, dia);
      } catch (_) {
        return null;
      }
    }

    // Número de serie de fecha de Excel (días desde 1899-12-30).
    final serie = double.tryParse(texto);
    if (serie != null) {
      return DateTime.utc(1899, 12, 30).add(Duration(days: serie.round()));
    }

    return null;
  }

  // ---------------------------------------------------------------------
  // Productos
  // ---------------------------------------------------------------------

  Future<ImportResultado> importarProductos({
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    final productos = ProductsLocalDatasource(_db);
    var insertados = 0;
    final errores = <String>[];

    for (var i = 0; i < filas.length; i++) {
      final datos = transformarFila(filas[i], encabezados, mapeo);
      final nombre = (datos['nombre'] as String?)?.trim() ?? '';
      if (nombre.isEmpty) {
        errores.add('Fila ${i + 2}: falta el nombre del producto.');
        continue;
      }
      try {
        String? categoriaId;
        final categoria = (datos['categoria'] as String?)?.trim();
        if (categoria != null && categoria.isNotEmpty) {
          categoriaId = await _obtenerOCrearCategoria(categoria);
        }
        final unidad = (datos['unidad'] as String?)?.trim();
        await productos.crearProducto(
          nombre: nombre,
          categoriaId: categoriaId,
          unidad: (unidad == null || unidad.isEmpty) ? 'unidad' : unidad,
          precioCompra: (datos['precioCompra'] as int?) ?? 0,
          precioVenta: (datos['precioVenta'] as int?) ?? 0,
          stockInicial: (datos['stockInicial'] as double?) ?? 0,
          stockMinimo: (datos['stockMinimo'] as double?) ?? 0,
          usuarioId: usuarioId,
        );
        insertados++;
      } catch (e) {
        errores.add('Fila ${i + 2}: $e');
      }
    }

    return ImportResultado(insertados: insertados, errores: errores);
  }

  // ---------------------------------------------------------------------
  // Gastos
  // ---------------------------------------------------------------------

  Future<ImportResultado> importarGastos({
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    final gastos = ExpensesLocalDatasource(_db);
    var insertados = 0;
    final errores = <String>[];

    for (var i = 0; i < filas.length; i++) {
      final datos = transformarFila(filas[i], encabezados, mapeo);
      final categoria = (datos['categoria'] as String?)?.trim() ?? '';
      final concepto = (datos['concepto'] as String?)?.trim() ?? '';
      final fecha = datos['fecha'] as DateTime?;
      final monto = datos['monto'] as int?;
      if (categoria.isEmpty ||
          concepto.isEmpty ||
          fecha == null ||
          monto == null) {
        errores.add('Fila ${i + 2}: faltan datos obligatorios del gasto.');
        continue;
      }
      try {
        await gastos.registrarGasto(
          categoria: categoria,
          concepto: concepto,
          fecha: fecha,
          montoCents: monto,
          usuarioId: usuarioId,
        );
        insertados++;
      } catch (e) {
        errores.add('Fila ${i + 2}: $e');
      }
    }

    return ImportResultado(insertados: insertados, errores: errores);
  }

  // ---------------------------------------------------------------------
  // Empleados
  // ---------------------------------------------------------------------

  Future<ImportResultado> importarEmpleados({
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    final empleados = EmployeesLocalDatasource(_db);
    var insertados = 0;
    final errores = <String>[];

    for (var i = 0; i < filas.length; i++) {
      final datos = transformarFila(filas[i], encabezados, mapeo);
      final nombre = (datos['nombre'] as String?)?.trim() ?? '';
      final fechaIngreso = datos['fechaIngreso'] as DateTime?;
      if (nombre.isEmpty || fechaIngreso == null) {
        errores.add('Fila ${i + 2}: faltan datos obligatorios del empleado.');
        continue;
      }
      try {
        final tipoTexto = (datos['tipo'] as String?)?.trim();
        final tipo = TipoEmpleado.values.firstWhere(
          (t) => t.name == tipoTexto,
          orElse: () => TipoEmpleado.ventas,
        );
        await empleados.crearEmpleado(
          tipo: tipo,
          nombre: nombre,
          cedula: (datos['cedula'] as String?)?.trim(),
          direccion: (datos['direccion'] as String?)?.trim(),
          telefono: (datos['telefono'] as String?)?.trim(),
          fechaIngreso: fechaIngreso,
          salarioCents: datos['salario'] as int?,
          frecuenciaPago: (datos['frecuenciaPago'] as String?)?.trim(),
          usuarioId: usuarioId,
        );
        insertados++;
      } catch (e) {
        errores.add('Fila ${i + 2}: $e');
      }
    }

    return ImportResultado(insertados: insertados, errores: errores);
  }

  // ---------------------------------------------------------------------
  // Compras (históricas, sin movimiento de inventario ni caja)
  // ---------------------------------------------------------------------

  Future<ImportResultado> importarCompras({
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    final compras = PurchasesLocalDatasource(_db);
    var insertados = 0;
    final errores = <String>[];

    for (var i = 0; i < filas.length; i++) {
      final datos = transformarFila(filas[i], encabezados, mapeo);
      final productoNombre = (datos['producto'] as String?)?.trim() ?? '';
      final cantidad = datos['cantidad'] as double?;
      final costoUnitario = datos['costoUnitario'] as int?;
      final fecha = datos['fecha'] as DateTime?;
      if (productoNombre.isEmpty ||
          cantidad == null ||
          costoUnitario == null ||
          fecha == null) {
        errores.add('Fila ${i + 2}: faltan datos obligatorios de la compra.');
        continue;
      }
      try {
        final productoId = await _obtenerOCrearProducto(
          productoNombre,
          usuarioId,
        );
        String? proveedorId;
        final proveedorNombre = (datos['proveedor'] as String?)?.trim();
        if (proveedorNombre != null && proveedorNombre.isNotEmpty) {
          proveedorId = await _obtenerOCrearProveedor(compras, proveedorNombre);
        }
        final numeroFactura = (datos['numeroFactura'] as String?)?.trim();
        final total = (costoUnitario * cantidad).round();

        await _db.transaction(() async {
          final compraId = generateUuidV4();
          await _db
              .into(_db.compras)
              .insert(
                ComprasCompanion.insert(
                  id: Value(compraId),
                  proveedorId: Value(proveedorId),
                  numeroFactura: Value(
                    (numeroFactura == null || numeroFactura.isEmpty)
                        ? null
                        : numeroFactura,
                  ),
                  total: total,
                  pagadaDeCaja: const Value(false),
                  estado: EstadoCompra.completada,
                  usuarioId: usuarioId,
                  fecha: fecha,
                ),
              );
          await _db
              .into(_db.compraItems)
              .insert(
                CompraItemsCompanion.insert(
                  compraId: compraId,
                  productoId: productoId,
                  cantidad: cantidad,
                  costoUnitario: costoUnitario,
                ),
              );
          await _db
              .into(_db.auditoria)
              .insert(
                AuditoriaCompanion.insert(
                  usuarioId: usuarioId,
                  accion: 'importar',
                  modulo: 'compras',
                  entidadId: Value(compraId),
                  datosDespues: Value(
                    jsonEncode({
                      'productoId': productoId,
                      'cantidad': cantidad,
                      'total': total,
                    }),
                  ),
                ),
              );
        });
        insertados++;
      } catch (e) {
        errores.add('Fila ${i + 2}: $e');
      }
    }

    return ImportResultado(insertados: insertados, errores: errores);
  }

  // ---------------------------------------------------------------------
  // Ventas (históricas, sin movimiento de inventario ni caja real)
  // ---------------------------------------------------------------------

  Future<ImportResultado> importarVentas({
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    var insertados = 0;
    final errores = <String>[];
    String? cajaSesionId;

    for (var i = 0; i < filas.length; i++) {
      final datos = transformarFila(filas[i], encabezados, mapeo);
      final productoNombre = (datos['producto'] as String?)?.trim() ?? '';
      final cantidad = datos['cantidad'] as double?;
      final precioUnitario = datos['precioUnitario'] as int?;
      final costoUnitario = datos['costoUnitario'] as int?;
      final fecha = datos['fecha'] as DateTime?;
      if (productoNombre.isEmpty ||
          cantidad == null ||
          precioUnitario == null ||
          costoUnitario == null ||
          fecha == null) {
        errores.add('Fila ${i + 2}: faltan datos obligatorios de la venta.');
        continue;
      }
      try {
        final productoId = await _obtenerOCrearProducto(
          productoNombre,
          usuarioId,
        );
        cajaSesionId ??= await _obtenerOCrearCajaImportacion(usuarioId);
        final total = (precioUnitario * cantidad).round();
        final ganancia = ((precioUnitario - costoUnitario) * cantidad).round();

        await _db.transaction(() async {
          final ventaId = generateUuidV4();
          await _db
              .into(_db.ventas)
              .insert(
                VentasCompanion.insert(
                  id: Value(ventaId),
                  tipo: TipoVenta.detallada,
                  total: total,
                  ganancia: ganancia,
                  cajaSesionId: cajaSesionId!,
                  usuarioId: usuarioId,
                  estado: EstadoVenta.completada,
                  nota: const Value('Importado'),
                  fecha: fecha,
                ),
              );
          await _db
              .into(_db.ventaItems)
              .insert(
                VentaItemsCompanion.insert(
                  ventaId: ventaId,
                  productoId: productoId,
                  cantidad: cantidad,
                  precioUnitario: precioUnitario,
                  costoUnitario: costoUnitario,
                ),
              );
          await _db
              .into(_db.auditoria)
              .insert(
                AuditoriaCompanion.insert(
                  usuarioId: usuarioId,
                  accion: 'importar',
                  modulo: 'ventas',
                  entidadId: Value(ventaId),
                  datosDespues: Value(
                    jsonEncode({
                      'productoId': productoId,
                      'cantidad': cantidad,
                      'total': total,
                      'ganancia': ganancia,
                    }),
                  ),
                ),
              );
        });
        insertados++;
      } catch (e) {
        errores.add('Fila ${i + 2}: $e');
      }
    }

    return ImportResultado(insertados: insertados, errores: errores);
  }

  // ---------------------------------------------------------------------
  // Find-or-create auxiliares
  // ---------------------------------------------------------------------

  Future<String> _obtenerOCrearCategoria(String nombre) async {
    final existente =
        await (_db.select(_db.categorias)
              ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (existente != null) return existente.id;
    final categoria = await ProductsLocalDatasource(_db).crearCategoria(nombre);
    return categoria.id;
  }

  Future<String> _obtenerOCrearProducto(String nombre, String usuarioId) async {
    final existente =
        await (_db.select(_db.productos)
              ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (existente != null) return existente.id;
    return ProductsLocalDatasource(_db).crearProducto(
      nombre: nombre,
      unidad: 'unidad',
      precioCompra: 0,
      precioVenta: 0,
      stockInicial: 0,
      stockMinimo: 0,
      usuarioId: usuarioId,
    );
  }

  Future<String> _obtenerOCrearProveedor(
    PurchasesLocalDatasource compras,
    String nombre,
  ) async {
    final existente =
        await (_db.select(_db.proveedores)
              ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (existente != null) return existente.id;
    final proveedor = await compras.crearProveedor(nombre: nombre);
    return proveedor.id;
  }

  /// Busca la sesión de caja sintética "Importación histórica" (marcada en
  /// `auditoria`) o crea una nueva, cerrada y en cero, para usar como
  /// `cajaSesionId` de las ventas importadas (FK obligatoria sin impacto
  /// real en caja).
  Future<String> _obtenerOCrearCajaImportacion(String usuarioId) async {
    final marcador =
        await (_db.select(_db.auditoria)
              ..where(
                (t) =>
                    t.modulo.equals('importacion') &
                    t.accion.equals('caja_importacion'),
              )
              ..limit(1))
            .getSingleOrNull();
    if (marcador?.entidadId != null) {
      final existente = await (_db.select(
        _db.cajaSesiones,
      )..where((t) => t.id.equals(marcador!.entidadId!))).getSingleOrNull();
      if (existente != null) return existente.id;
    }

    final id = generateUuidV4();
    final ahora = DateTime.now().toUtc();
    await _db
        .into(_db.cajaSesiones)
        .insert(
          CajaSesionesCompanion.insert(
            id: Value(id),
            fechaApertura: ahora,
            montoApertura: 0,
            usuarioApertura: usuarioId,
            fechaCierre: Value(ahora),
            montoEsperado: const Value(0),
            montoContado: const Value(0),
            diferencia: const Value(0),
            estado: EstadoCajaSesion.cerrada,
          ),
        );
    await _db
        .into(_db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: usuarioId,
            accion: 'caja_importacion',
            modulo: 'importacion',
            entidadId: Value(id),
            datosDespues: Value(
              jsonEncode({'motivo': 'Sesión sintética para ventas importadas'}),
            ),
          ),
        );
    return id;
  }
}
