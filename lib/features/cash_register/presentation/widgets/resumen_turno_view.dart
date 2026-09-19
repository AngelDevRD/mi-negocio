import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/entities/resumen_turno.dart';
import '../providers/cash_register_providers.dart';

/// "Resumen del turno" de una sesión: carga el arqueo y lo muestra. Sirve tanto
/// para el cierre (sesión abierta) como para el detalle de un cierre pasado.
class ResumenTurnoSeccion extends ConsumerWidget {
  const ResumenTurnoSeccion({super.key, required this.sesionId});

  final String sesionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenTurnoProvider(sesionId));
    return resumenAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LoadingView(),
      ),
      error: (error, stackTrace) => ErrorState(
        compacto: true,
        mensaje: 'No se pudo cargar el resumen del turno.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(resumenTurnoProvider(sesionId)),
      ),
      data: (resumen) =>
          resumen == null ? const SizedBox.shrink() : ResumenTurnoView(resumen),
    );
  }
}

/// Arqueo del turno en tres bloques: lo VENDIDO por método (el fiado se
/// informa aparte porque no entra a la caja), los ABONOS cobrados y cómo se
/// arma el EFECTIVO esperado. Sin colores de acento: el signo y las etiquetas
/// dicen qué suma y qué resta.
class ResumenTurnoView extends StatelessWidget {
  const ResumenTurnoView(this.resumen, {super.key});

  final ResumenTurno resumen;

  @override
  Widget build(BuildContext context) {
    final r = resumen;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen del turno',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const _Bloque('Ventas del turno'),
            _Linea('Efectivo', r.ventasEfectivo),
            _Linea('Tarjeta', r.ventasTarjeta),
            _Linea('Transferencia', r.ventasTransferencia),
            _Linea('Fiado (no entra a la caja)', r.ventasFiado),
            _Linea('Total vendido', r.totalVentas, destacada: true),
            if (!r.totalAbonos.isZero) ...[
              const SizedBox(height: AppSpacing.md),
              const _Bloque('Abonos de clientes'),
              if (!r.abonosEfectivo.isZero)
                _Linea('Efectivo', r.abonosEfectivo),
              if (!r.abonosTarjeta.isZero) _Linea('Tarjeta', r.abonosTarjeta),
              if (!r.abonosTransferencia.isZero)
                _Linea('Transferencia', r.abonosTransferencia),
            ],
            const SizedBox(height: AppSpacing.md),
            const _Bloque('Efectivo en caja'),
            _Linea('Apertura', r.montoApertura),
            _Linea('Ventas en efectivo', r.ventasEfectivo, signo: '+'),
            if (!r.abonosEfectivo.isZero)
              _Linea('Abonos en efectivo', r.abonosEfectivo, signo: '+'),
            if (!r.entradasManuales.isZero)
              _Linea('Entradas manuales', r.entradasManuales, signo: '+'),
            if (!r.salidasManuales.isZero)
              _Linea('Salidas manuales', r.salidasManuales, signo: '-'),
            if (!r.gastos.isZero)
              _Linea('Gastos pagados de caja', r.gastos, signo: '-'),
            if (!r.compras.isZero)
              _Linea('Compras pagadas de caja', r.compras, signo: '-'),
            if (!r.pagosEmpleados.isZero)
              _Linea('Pagos a empleados', r.pagosEmpleados, signo: '-'),
            const Divider(height: AppSpacing.lg),
            _Linea('Efectivo esperado', r.efectivoEsperado, destacada: true),
          ],
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        titulo,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Fila "etiqueta ....... monto". Con [signo] ("+" o "-") el monto lleva ese
/// signo delante, para que se lea qué suma y qué resta sin depender del color.
class _Linea extends StatelessWidget {
  const _Linea(this.etiqueta, this.monto, {this.signo, this.destacada = false});

  final String etiqueta;
  final Money monto;
  final String? signo;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final estilo = destacada
        ? textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: estilo)),
          const SizedBox(width: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: signo == null
                ? MoneyText(monto, style: estilo, textAlign: TextAlign.right)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$signo${monto.format()}',
                      softWrap: false,
                      style: estilo?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
