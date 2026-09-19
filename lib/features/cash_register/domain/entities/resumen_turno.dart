import '../../../../core/utils/money.dart';

/// Arqueo completo de una sesión de caja (RF-CAJ): qué se vendió y cobró por
/// cada método de pago, qué entró y salió a mano, y cuánto efectivo debe haber.
///
/// Solo el EFECTIVO se mueve por la caja física: tarjeta, transferencia y fiado
/// se informan aparte para que el dueño vea el turno completo, pero no forman
/// parte de [efectivoEsperado]. Las salidas (gastos, compras, pagos, salidas
/// manuales) se guardan como montos POSITIVOS: la etiqueta ya dice que restan.
class ResumenTurno {
  const ResumenTurno({
    required this.montoApertura,
    required this.ventasEfectivo,
    required this.ventasTarjeta,
    required this.ventasTransferencia,
    required this.ventasFiado,
    required this.abonosEfectivo,
    required this.abonosTarjeta,
    required this.abonosTransferencia,
    required this.entradasManuales,
    required this.salidasManuales,
    required this.gastos,
    required this.compras,
    required this.pagosEmpleados,
    required this.efectivoEsperado,
  });

  final Money montoApertura;

  /// Ventas completadas de la sesión, por método de pago.
  final Money ventasEfectivo;
  final Money ventasTarjeta;
  final Money ventasTransferencia;
  final Money ventasFiado;

  /// Abonos de clientes con fiado cobrados durante la sesión, por método.
  final Money abonosEfectivo;
  final Money abonosTarjeta;
  final Money abonosTransferencia;

  final Money entradasManuales;
  final Money salidasManuales;

  /// Pagados desde la caja.
  final Money gastos;
  final Money compras;
  final Money pagosEmpleados;

  /// Apertura + todo lo que entró y salió de la caja (sin el retiro del cierre).
  final Money efectivoEsperado;

  Money get totalVentas =>
      ventasEfectivo + ventasTarjeta + ventasTransferencia + ventasFiado;

  Money get totalAbonos => abonosEfectivo + abonosTarjeta + abonosTransferencia;

  /// Todo lo pagado desde la caja por gastos, compras y pagos a empleados.
  Money get totalPagosDeCaja => gastos + compras + pagosEmpleados;
}
