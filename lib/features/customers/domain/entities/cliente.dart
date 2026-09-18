import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/utils/money.dart';

part 'cliente.freezed.dart';

/// Cliente con fiado. El [saldo] NO está guardado: es la suma de sus
/// movimientos (libro mayor); positivo = el cliente debe.
@freezed
abstract class Cliente with _$Cliente {
  const factory Cliente({
    required String id,
    required String nombre,
    String? telefono,
    String? nota,

    /// `null` = sin límite de crédito.
    Money? limiteCredito,
    required bool activo,
    required Money saldo,
  }) = _Cliente;
}

/// Movimiento del libro de cuenta de un cliente. [monto] lleva signo: cargo
/// positivo; abono y anulación negativos.
@freezed
abstract class MovimientoCliente with _$MovimientoCliente {
  const factory MovimientoCliente({
    required String id,
    required TipoMovimientoCliente tipo,
    required Money monto,
    String? ventaId,
    MetodoPago? metodoPago,
    String? nota,
    required DateTime fecha,
    required String usuarioNombre,
  }) = _MovimientoCliente;
}
