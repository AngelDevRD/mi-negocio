import '../../../../core/errors/result.dart';
import '../../domain/entities/import_target.dart';
import '../../domain/repositories/import_repository.dart';
import '../datasources/ai_mapping_remote_datasource.dart';
import '../datasources/import_local_datasource.dart';
import '../services/excel_import_reader.dart';

class ImportRepositoryImpl implements ImportRepository {
  ImportRepositoryImpl({required this.local, required this.remote});

  final ImportLocalDatasource local;
  final AiMappingRemoteDatasource remote;

  @override
  Result<List<HojaImportada>> leerExcel(List<int> bytes) {
    try {
      final hojas = ExcelImportReader.leer(bytes);
      if (hojas.isEmpty) {
        return const Result.fail(
          ValidationFailure('El archivo no tiene datos para importar.'),
        );
      }
      return Result.ok(hojas);
    } catch (e) {
      return Result.fail(ValidationFailure('No se pudo leer el archivo: $e'));
    }
  }

  @override
  Map<String, Object?> transformarFila(
    List<String> fila,
    List<String> encabezados,
    Map<String, ColumnMapping> mapeo,
  ) {
    return local.transformarFila(fila, encabezados, mapeo);
  }

  @override
  Future<Result<AiMappingResponse>> sugerirMapeo({
    required ImportTargetType targetType,
    required List<String> headers,
    required List<List<String>> sampleRows,
  }) async {
    try {
      final respuesta = await remote.mapColumns(
        targetType: targetType,
        headers: headers,
        sampleRows: sampleRows,
      );
      if (!respuesta.ok) {
        return Result.fail(
          NetworkFailure(respuesta.error ?? 'No se pudo obtener un mapeo.'),
        );
      }
      return Result.ok(respuesta);
    } catch (e) {
      return Result.fail(NetworkFailure('Error de conexión con la IA: $e'));
    }
  }

  @override
  Future<Result<ImportResultado>> importar({
    required ImportTargetType targetType,
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    try {
      final resultado = switch (targetType) {
        ImportTargetType.productos => await local.importarProductos(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        ),
        ImportTargetType.gastos => await local.importarGastos(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        ),
        ImportTargetType.empleados => await local.importarEmpleados(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        ),
        ImportTargetType.compras => await local.importarCompras(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        ),
        ImportTargetType.ventas => await local.importarVentas(
          encabezados: encabezados,
          filas: filas,
          mapeo: mapeo,
          usuarioId: usuarioId,
        ),
      };
      return Result.ok(resultado);
    } catch (e) {
      return Result.fail(DatabaseFailure('No se pudo importar: $e'));
    }
  }
}
