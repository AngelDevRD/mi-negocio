import '../../../../core/errors/result.dart';
import '../../data/datasources/ai_mapping_remote_datasource.dart';
import '../../data/services/excel_import_reader.dart';
import '../entities/import_target.dart';

/// Acceso a la importación de datos de migración desde Excel (FASE 20).
abstract class ImportRepository {
  /// Lee un archivo Excel y devuelve sus hojas con encabezados y filas.
  Result<List<HojaImportada>> leerExcel(List<int> bytes);

  /// Aplica [mapeo] a una fila cruda para mostrarla en la vista previa.
  Map<String, Object?> transformarFila(
    List<String> fila,
    List<String> encabezados,
    Map<String, ColumnMapping> mapeo,
  );

  /// Pide a la IA un mapeo sugerido de columnas para [targetType].
  Future<Result<AiMappingResponse>> sugerirMapeo({
    required ImportTargetType targetType,
    required List<String> headers,
    required List<List<String>> sampleRows,
  });

  /// Inserta todas las [filas] aplicando [mapeo], según [targetType].
  Future<Result<ImportResultado>> importar({
    required ImportTargetType targetType,
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  });
}
