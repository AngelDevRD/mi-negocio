import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_local_datasource.dart';

/// Implementación de ventas (RF-VEN): registro, anulación y apertura mínima
/// de caja (RN-01).
class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._local);

  final SalesLocalDatasource _local;

  VentaItem _itemAEntidad((db.VentaItem, String) row) {
    final (item, productoNombre) = row;
    return VentaItem(
      productoId: item.productoId,
      productoNombre: productoNombre,
      cantidad: item.cantidad,
      precioUnitario: Money(item.precioUnitario),
      costoUnitario: Money(item.costoUnitario),
    );
  }

  Venta _ventaAEntidad(
    (db.Venta, String) row, {
    List<VentaItem> items = const [],
  }) {
    final (venta, usuarioNombre) = row;
    return Venta(
      id: venta.id,
      tipo: venta.tipo,
      total: Money(venta.total),
      ganancia: Money(venta.ganancia),
      estado: venta.estado,
      nota: venta.nota,
      usuarioNombre: usuarioNombre,
      fecha: venta.fecha,
      items: items,
    );
  }

  @override
  Stream<List<Venta>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  }) {
    return _local
        .watchVentas(estado: estado, desde: desde, hasta: hasta)
        .map((rows) => rows.map((row) => _ventaAEntidad(row)).toList());
  }

  @override
  Future<Venta?> obtenerVenta(String id) async {
    final fila = await _local.obtenerVenta(id);
    if (fila == null) return null;
    final items = await _local.obtenerItemsVenta(id);
    return _ventaAEntidad(fila, items: items.map(_itemAEntidad).toList());
  }

  @override
  Future<Result<String>> registrarVenta({
    required TipoVenta tipo,
    required List<ItemVentaInput> items,
    String? nota,
    required String usuarioId,
  }) async {
    if (items.isEmpty) {
      return const Result.fail(
        ValidationFailure('La venta debe tener al menos un producto.'),
      );
    }
    for (final item in items) {
      if (item.cantidad <= 0) {
        return Result.fail(
          ValidationFailure(
            'La cantidad de "${item.productoNombre}" debe ser mayor que cero.',
          ),
        );
      }
      if (item.precioUnitario.cents < 0) {
        return Result.fail(
          ValidationFailure(
            'El precio de "${item.productoNombre}" no puede ser negativo.',
          ),
        );
      }
      if (!await _local.existeProducto(item.productoId)) {
        return Result.fail(
          ValidationFailure(
            'El producto "${item.productoNombre}" no existe o fue eliminado.',
          ),
        );
      }
    }

    final cajaSesionId = await _local.obtenerCajaAbiertaId();
    if (cajaSesionId == null) {
      return const Result.fail(
        BusinessRuleFailure(
          'Debe abrir una caja antes de registrar una venta.',
          rule: 'RN-01',
        ),
      );
    }

    final ventaId = await _local.registrarVenta(
      tipo: tipo,
      items: items
          .map(
            (item) => VentaItemEntrada(
              productoId: item.productoId,
              cantidad: item.cantidad,
              precioUnitarioCents: item.precioUnitario.cents,
            ),
          )
          .toList(),
      nota: nota,
      cajaSesionId: cajaSesionId,
      usuarioId: usuarioId,
    );
    return Result.ok(ventaId);
  }

  @override
  Future<Result<void>> anularVenta(
    String id, {
    required String usuarioId,
  }) async {
    final venta = await obtenerVenta(id);
    if (venta == null) {
      return const Result.fail(ValidationFailure('La venta no existe.'));
    }
    if (venta.estado == EstadoVenta.anulada) {
      return const Result.fail(ValidationFailure('La venta ya está anulada.'));
    }
    await _local.anularVenta(id, usuarioId: usuarioId);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> abrirCaja({
    required Money montoApertura,
    required String usuarioId,
  }) async {
    if (montoApertura.cents < 0) {
      return const Result.fail(
        ValidationFailure('El monto de apertura no puede ser negativo.'),
      );
    }
    if (await _local.obtenerCajaAbiertaId() != null) {
      return const Result.fail(
        ValidationFailure('Ya existe una sesión de caja abierta.'),
      );
    }
    await _local.abrirCaja(
      montoAperturaCents: montoApertura.cents,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }
}
