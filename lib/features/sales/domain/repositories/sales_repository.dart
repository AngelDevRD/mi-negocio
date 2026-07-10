import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../entities/venta.dart';

/// Operaciones de ventas (RF-VEN): listado/detalle, registro y anulación.
abstract interface class SalesRepository {
  /// Ventas registradas, más reciente primero, con filtros opcionales.
  Stream<List<Venta>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  });

  /// Venta con sus ítems, o `null` si no existe.
  Future<Venta?> obtenerVenta(String id);

  /// Registra una venta completa (RF-VEN/RN-05): requiere caja abierta
  /// (RN-01), descuenta inventario por ítem vía
  /// `InventoryRepository.applyMovement`, captura el costo vigente de cada
  /// producto para calcular la ganancia, registra una entrada en
  /// `caja_movimientos` y auditoría. Devuelve el id de la venta creada.
  Future<Result<String>> registrarVenta({
    required TipoVenta tipo,
    required List<ItemVentaInput> items,
    String? nota,
    required String usuarioId,
  });

  /// Anula una venta completada (RF-VEN/RN-10, solo Administrador): revierte
  /// el stock de cada ítem, registra una salida compensatoria en
  /// `caja_movimientos`, marca la venta como anulada y registra auditoría.
  Future<Result<void>> anularVenta(String id, {required String usuarioId});

  /// Abre una nueva sesión de caja (RN-01: requisito mínimo para vender si
  /// no hay una sesión abierta).
  Future<Result<void>> abrirCaja({
    required Money montoApertura,
    required String usuarioId,
  });
}
