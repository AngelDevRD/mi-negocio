/// Tipos de datos que se pueden importar desde un Excel de migración
/// (FASE 20, RF-IMP).
enum ImportTargetType { productos, gastos, empleados, compras, ventas }

extension ImportTargetTypeX on ImportTargetType {
  String get etiqueta => switch (this) {
    ImportTargetType.productos => 'Productos',
    ImportTargetType.gastos => 'Gastos',
    ImportTargetType.empleados => 'Empleados',
    ImportTargetType.compras => 'Compras',
    ImportTargetType.ventas => 'Ventas',
  };
}

/// Transformación a aplicar a una columna de Excel antes de insertarla.
enum ColumnTransform { texto, numero, dinero, fecha, enumerado, siNo }

extension ColumnTransformX on ColumnTransform {
  String get etiqueta => switch (this) {
    ColumnTransform.texto => 'Texto',
    ColumnTransform.numero => 'Número',
    ColumnTransform.dinero => 'Dinero',
    ColumnTransform.fecha => 'Fecha',
    ColumnTransform.enumerado => 'Lista de valores',
    ColumnTransform.siNo => 'Sí/No',
  };
}

/// Especificación de un campo destino de la app para un [ImportTargetType].
class ImportFieldSpec {
  const ImportFieldSpec({
    required this.campo,
    required this.etiqueta,
    required this.transform,
    this.requerido = false,
    this.enumOpciones,
  });

  /// Nombre interno del campo (clave de [camposImportacion] y de
  /// [ColumnMapping.campo]).
  final String campo;

  /// Nombre legible para la UI.
  final String etiqueta;
  final ColumnTransform transform;
  final bool requerido;

  /// Valores válidos cuando [transform] es [ColumnTransform.enumerado].
  final List<String>? enumOpciones;
}

/// Campos destino disponibles por tipo de importación, en el orden en que
/// se muestran en la pantalla de mapeo.
const Map<ImportTargetType, List<ImportFieldSpec>> camposImportacion = {
  ImportTargetType.productos: [
    ImportFieldSpec(
      campo: 'nombre',
      etiqueta: 'Nombre del producto',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'categoria',
      etiqueta: 'Categoría',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'unidad',
      etiqueta: 'Unidad',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'precioCompra',
      etiqueta: 'Precio de compra',
      transform: ColumnTransform.dinero,
    ),
    ImportFieldSpec(
      campo: 'precioVenta',
      etiqueta: 'Precio de venta',
      transform: ColumnTransform.dinero,
    ),
    ImportFieldSpec(
      campo: 'stockInicial',
      etiqueta: 'Stock inicial',
      transform: ColumnTransform.numero,
    ),
    ImportFieldSpec(
      campo: 'stockMinimo',
      etiqueta: 'Stock mínimo',
      transform: ColumnTransform.numero,
    ),
  ],
  ImportTargetType.gastos: [
    ImportFieldSpec(
      campo: 'categoria',
      etiqueta: 'Categoría',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'concepto',
      etiqueta: 'Concepto',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'fecha',
      etiqueta: 'Fecha',
      transform: ColumnTransform.fecha,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'monto',
      etiqueta: 'Monto',
      transform: ColumnTransform.dinero,
      requerido: true,
    ),
  ],
  ImportTargetType.empleados: [
    ImportFieldSpec(
      campo: 'tipo',
      etiqueta: 'Tipo (ventas/delivery)',
      transform: ColumnTransform.enumerado,
      requerido: true,
      enumOpciones: ['ventas', 'delivery'],
    ),
    ImportFieldSpec(
      campo: 'nombre',
      etiqueta: 'Nombre',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'cedula',
      etiqueta: 'Cédula',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'direccion',
      etiqueta: 'Dirección',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'telefono',
      etiqueta: 'Teléfono',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'fechaIngreso',
      etiqueta: 'Fecha de ingreso',
      transform: ColumnTransform.fecha,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'salario',
      etiqueta: 'Salario',
      transform: ColumnTransform.dinero,
    ),
    ImportFieldSpec(
      campo: 'frecuenciaPago',
      etiqueta: 'Frecuencia de pago',
      transform: ColumnTransform.texto,
    ),
  ],
  ImportTargetType.compras: [
    ImportFieldSpec(
      campo: 'proveedor',
      etiqueta: 'Proveedor',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'producto',
      etiqueta: 'Producto',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'cantidad',
      etiqueta: 'Cantidad',
      transform: ColumnTransform.numero,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'costoUnitario',
      etiqueta: 'Costo unitario',
      transform: ColumnTransform.dinero,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'numeroFactura',
      etiqueta: 'Número de factura',
      transform: ColumnTransform.texto,
    ),
    ImportFieldSpec(
      campo: 'fecha',
      etiqueta: 'Fecha',
      transform: ColumnTransform.fecha,
      requerido: true,
    ),
  ],
  ImportTargetType.ventas: [
    ImportFieldSpec(
      campo: 'producto',
      etiqueta: 'Producto',
      transform: ColumnTransform.texto,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'cantidad',
      etiqueta: 'Cantidad',
      transform: ColumnTransform.numero,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'precioUnitario',
      etiqueta: 'Precio unitario',
      transform: ColumnTransform.dinero,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'costoUnitario',
      etiqueta: 'Costo unitario',
      transform: ColumnTransform.dinero,
      requerido: true,
    ),
    ImportFieldSpec(
      campo: 'fecha',
      etiqueta: 'Fecha',
      transform: ColumnTransform.fecha,
      requerido: true,
    ),
  ],
};

/// Resultado de importar todas las filas de una hoja (FASE 20, RF-IMP-03).
class ImportResultado {
  const ImportResultado({required this.insertados, required this.errores});

  /// Cantidad de filas insertadas correctamente.
  final int insertados;

  /// Mensajes "Fila N: ..." de las filas que no se pudieron insertar.
  final List<String> errores;
}

/// Mapeo (sugerido por IA o editado por el usuario) de un campo de la app a
/// una columna del Excel.
class ColumnMapping {
  const ColumnMapping({
    required this.campo,
    this.columna,
    required this.transform,
    this.enumValores,
  });

  /// Nombre interno del campo destino ([ImportFieldSpec.campo]).
  final String campo;

  /// Encabezado de la columna del Excel asignada, o `null` si no se mapeó.
  final String? columna;
  final ColumnTransform transform;

  /// Para [ColumnTransform.enumerado]: mapeo de valor de Excel -> valor app.
  final Map<String, String>? enumValores;

  static const Object _sinCambio = Object();

  ColumnMapping copyWith({
    Object? columna = _sinCambio,
    ColumnTransform? transform,
    Object? enumValores = _sinCambio,
  }) {
    return ColumnMapping(
      campo: campo,
      columna: columna == _sinCambio ? this.columna : columna as String?,
      transform: transform ?? this.transform,
      enumValores: enumValores == _sinCambio
          ? this.enumValores
          : enumValores as Map<String, String>?,
    );
  }
}
