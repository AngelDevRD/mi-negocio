import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/ai_mapping_remote_datasource.dart';
import '../../data/datasources/import_local_datasource.dart';
import '../../data/repositories/import_repository_impl.dart';
import '../../data/services/excel_import_reader.dart';
import '../../domain/entities/import_target.dart';
import '../../domain/repositories/import_repository.dart';

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepositoryImpl(
    local: ImportLocalDatasource(ref.watch(appDatabaseProvider)),
    remote: SupabaseAiMappingRemoteDatasource(),
  );
});

/// Mapeo inicial (sin IA) para [tipo]: una entrada por cada campo definido
/// en [camposImportacion], sin columna asignada.
Map<String, ColumnMapping> mapeoInicial(ImportTargetType tipo) {
  return {
    for (final campo in camposImportacion[tipo]!)
      campo.campo: ColumnMapping(
        campo: campo.campo,
        transform: campo.transform,
        enumValores: campo.enumOpciones == null
            ? null
            : {for (final opcion in campo.enumOpciones!) opcion: opcion},
      ),
  };
}

/// Estado del asistente de importación (FASE 20).
class ImportState {
  const ImportState({
    this.hojas = const [],
    this.hojaSeleccionada = 0,
    this.targetType = ImportTargetType.productos,
    this.mapeo = const {},
    this.cargandoIA = false,
    this.advertenciasIA,
    this.cargandoImportacion = false,
    this.resultado,
    this.error,
  });

  final List<HojaImportada> hojas;
  final int hojaSeleccionada;
  final ImportTargetType targetType;
  final Map<String, ColumnMapping> mapeo;
  final bool cargandoIA;
  final List<String>? advertenciasIA;
  final bool cargandoImportacion;
  final ImportResultado? resultado;
  final String? error;

  HojaImportada? get hoja => hojas.isEmpty ? null : hojas[hojaSeleccionada];

  static const Object _sinCambio = Object();

  ImportState copyWith({
    List<HojaImportada>? hojas,
    int? hojaSeleccionada,
    ImportTargetType? targetType,
    Map<String, ColumnMapping>? mapeo,
    bool? cargandoIA,
    Object? advertenciasIA = _sinCambio,
    bool? cargandoImportacion,
    Object? resultado = _sinCambio,
    Object? error = _sinCambio,
  }) {
    return ImportState(
      hojas: hojas ?? this.hojas,
      hojaSeleccionada: hojaSeleccionada ?? this.hojaSeleccionada,
      targetType: targetType ?? this.targetType,
      mapeo: mapeo ?? this.mapeo,
      cargandoIA: cargandoIA ?? this.cargandoIA,
      advertenciasIA: advertenciasIA == _sinCambio
          ? this.advertenciasIA
          : advertenciasIA as List<String>?,
      cargandoImportacion: cargandoImportacion ?? this.cargandoImportacion,
      resultado: resultado == _sinCambio
          ? this.resultado
          : resultado as ImportResultado?,
      error: error == _sinCambio ? this.error : error as String?,
    );
  }
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);

class ImportController extends Notifier<ImportState> {
  ImportRepository get _repo => ref.read(importRepositoryProvider);

  @override
  ImportState build() => const ImportState();

  /// Lee el Excel elegido por el usuario. Devuelve un mensaje de error, o
  /// `null` si pudo leerse correctamente.
  String? cargarArchivo(List<int> bytes) {
    final resultado = _repo.leerExcel(bytes);
    return resultado.when(
      ok: (hojas) {
        state = ImportState(
          hojas: hojas,
          targetType: state.targetType,
          mapeo: mapeoInicial(state.targetType),
        );
        return null;
      },
      fail: (failure) => failure.message,
    );
  }

  void seleccionarHoja(int indice) {
    state = state.copyWith(
      hojaSeleccionada: indice,
      resultado: null,
      error: null,
    );
  }

  void seleccionarTipo(ImportTargetType tipo) {
    state = state.copyWith(
      targetType: tipo,
      mapeo: mapeoInicial(tipo),
      advertenciasIA: null,
      resultado: null,
      error: null,
    );
  }

  void actualizarMapeo(String campo, ColumnMapping mapping) {
    state = state.copyWith(mapeo: {...state.mapeo, campo: mapping});
  }

  /// Aplica el mapeo actual a las primeras [maxFilas] filas, para la vista
  /// previa.
  List<Map<String, Object?>> previaTransformada({int maxFilas = 5}) {
    final hoja = state.hoja;
    if (hoja == null) return [];
    return hoja.filas
        .take(maxFilas)
        .map(
          (fila) => _repo.transformarFila(fila, hoja.encabezados, state.mapeo),
        )
        .toList();
  }

  /// Pide a la IA un mapeo sugerido y lo combina con el mapeo actual.
  /// Devuelve un mensaje de error, o `null` si tuvo éxito.
  Future<String?> sugerirMapeoIA() async {
    final hoja = state.hoja;
    if (hoja == null) return 'Seleccione un archivo primero.';

    state = state.copyWith(cargandoIA: true, error: null);
    final resultado = await _repo.sugerirMapeo(
      targetType: state.targetType,
      headers: hoja.encabezados,
      sampleRows: hoja.filas.take(5).toList(),
    );
    return resultado.when(
      ok: (respuesta) {
        final mapeo = Map<String, ColumnMapping>.from(state.mapeo);
        respuesta.mapping?.forEach((campo, sugerencia) {
          final actual = mapeo[campo];
          if (actual == null) return;
          mapeo[campo] = actual.copyWith(
            columna: sugerencia.columna,
            transform: sugerencia.transform,
            enumValores: sugerencia.enumValores ?? actual.enumValores,
          );
        });
        state = state.copyWith(
          cargandoIA: false,
          mapeo: mapeo,
          advertenciasIA: respuesta.advertencias,
        );
        return null;
      },
      fail: (failure) {
        state = state.copyWith(cargandoIA: false, error: failure.message);
        return failure.message;
      },
    );
  }

  /// Importa todas las filas de la hoja seleccionada. Devuelve un mensaje
  /// de error, o `null` si tuvo éxito (el resultado queda en `state`).
  Future<String?> confirmarImportacion({required String usuarioId}) async {
    final hoja = state.hoja;
    if (hoja == null) return 'Seleccione un archivo primero.';

    state = state.copyWith(
      cargandoImportacion: true,
      resultado: null,
      error: null,
    );
    final resultado = await _repo.importar(
      targetType: state.targetType,
      encabezados: hoja.encabezados,
      filas: hoja.filas,
      mapeo: state.mapeo,
      usuarioId: usuarioId,
    );
    return resultado.when(
      ok: (valor) {
        state = state.copyWith(cargandoImportacion: false, resultado: valor);
        return null;
      },
      fail: (failure) {
        state = state.copyWith(
          cargandoImportacion: false,
          error: failure.message,
        );
        return failure.message;
      },
    );
  }

  void reiniciar() {
    state = const ImportState();
  }
}
