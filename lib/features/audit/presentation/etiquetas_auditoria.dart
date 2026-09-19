import 'package:flutter/material.dart';

import '../../../core/utils/money.dart';
import '../domain/entities/registro_auditoria.dart';

/// Acción de auditoría legible: ícono + texto (el valor guardado, p. ej.
/// `resetear_password`, es un identificador interno).
({IconData icono, String texto}) etiquetaDeAccion(String accion) {
  switch (accion) {
    case 'crear':
      return (icono: Icons.add_circle_outline, texto: 'Crear');
    case 'editar':
    case 'actualizar':
      return (icono: Icons.edit_outlined, texto: 'Editar');
    case 'anular':
      return (icono: Icons.block_outlined, texto: 'Anular');
    case 'eliminar':
      return (icono: Icons.delete_outline, texto: 'Eliminar');
    case 'abrir':
      return (icono: Icons.lock_open_outlined, texto: 'Abrir');
    case 'cerrar':
      return (icono: Icons.lock_outline, texto: 'Cerrar');
    case 'importar':
    case 'caja_importacion':
      return (icono: Icons.file_upload_outlined, texto: 'Importar');
    case 'activar':
      return (icono: Icons.check_circle_outline, texto: 'Activar');
    case 'desactivar':
      return (icono: Icons.pause_circle_outline, texto: 'Desactivar');
    case 'entrada_manual':
      return (icono: Icons.south_west, texto: 'Entrada de efectivo');
    case 'salida_manual':
      return (icono: Icons.north_east, texto: 'Salida de efectivo');
    case 'abonar':
      return (icono: Icons.payments_outlined, texto: 'Abonar');
    case 'resetear_password':
      return (
        icono: Icons.lock_reset_outlined,
        texto: 'Restablecer contraseña',
      );
    case 'cambiar_password':
      return (icono: Icons.password_outlined, texto: 'Cambiar contraseña');
    default:
      return (icono: Icons.history, texto: _capitalizar(accion));
  }
}

/// Módulo legible ("ventas" → "Ventas").
String etiquetaDeModulo(String modulo) => switch (modulo) {
  'configuracion' => 'Configuración',
  'importacion' => 'Importación',
  _ => _capitalizar(modulo),
};

String _capitalizar(String texto) {
  final limpio = texto.replaceAll('_', ' ').trim();
  if (limpio.isEmpty) return texto;
  return limpio[0].toUpperCase() + limpio.substring(1);
}

/// Detalle corto de SOBRE QUÉ trata el registro, sacado de lo que ya guarda
/// (nombre, concepto o motivo; en ventas/compras el total). Es `null` cuando el
/// registro no guardó nada legible (p. ej. solo `activo: false`): no se inventa
/// ni se consulta la entidad.
String? detalleDeRegistro(RegistroAuditoria registro) {
  final datos = registro.datosDespues ?? registro.datosAntes;
  if (datos == null) return null;
  String? texto(String clave) {
    final valor = datos[clave];
    if (valor is! String) return null;
    final limpio = valor.trim();
    return limpio.isEmpty ? null : limpio;
  }

  final nombre = texto('nombre') ?? texto('concepto') ?? texto('motivo');
  final monto = datos['monto'];
  if (nombre != null) {
    return monto is int ? '$nombre · ${Money(monto).format()}' : nombre;
  }
  final total = datos['total'];
  if (total is int &&
      (registro.modulo == 'ventas' || registro.modulo == 'compras')) {
    return 'Total ${Money(total).format()}';
  }
  return null;
}
