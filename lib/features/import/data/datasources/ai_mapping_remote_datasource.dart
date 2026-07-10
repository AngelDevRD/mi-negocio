import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/import_target.dart';

/// Mapeo sugerido por la IA para un campo destino.
class AiColumnMapping {
  const AiColumnMapping({
    this.columna,
    required this.transform,
    this.enumValores,
  });

  final String? columna;
  final ColumnTransform transform;
  final Map<String, String>? enumValores;

  factory AiColumnMapping.fromJson(Map<String, dynamic> json) {
    return AiColumnMapping(
      columna: json['columna'] as String?,
      transform: _transformDesdeNombre(json['transform'] as String?),
      enumValores: (json['enumValores'] as Map?)?.map(
        (clave, valor) => MapEntry(clave.toString(), valor.toString()),
      ),
    );
  }

  /// La edge function `ai` usa los nombres `enum`/`si_no` (ver
  /// `TRANSFORMS_VALIDOS` en `supabase/functions/ai/index.ts`), distintos a
  /// los del enum Dart [ColumnTransform].
  static ColumnTransform _transformDesdeNombre(String? nombre) {
    switch (nombre) {
      case 'enum':
        return ColumnTransform.enumerado;
      case 'si_no':
        return ColumnTransform.siNo;
      default:
        return ColumnTransform.values.firstWhere(
          (t) => t.name == nombre,
          orElse: () => ColumnTransform.texto,
        );
    }
  }
}

/// Respuesta de la edge function `ai`, acción `mapColumns`.
class AiMappingResponse {
  const AiMappingResponse({
    required this.ok,
    this.error,
    this.mapping,
    this.advertencias,
  });

  final bool ok;
  final String? error;
  final Map<String, AiColumnMapping>? mapping;
  final List<String>? advertencias;
}

/// Cliente de la edge function `ai` para el mapeo asistido de columnas
/// (FASE 20, RF-IMP-02). Abstracto para poder simularlo en tests.
abstract class AiMappingRemoteDatasource {
  Future<AiMappingResponse> mapColumns({
    required ImportTargetType targetType,
    required List<String> headers,
    required List<List<String>> sampleRows,
  });
}

class SupabaseAiMappingRemoteDatasource implements AiMappingRemoteDatasource {
  @override
  Future<AiMappingResponse> mapColumns({
    required ImportTargetType targetType,
    required List<String> headers,
    required List<List<String>> sampleRows,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'ai',
      body: {
        'action': 'mapColumns',
        'targetType': targetType.name,
        'headers': headers,
        'sampleRows': sampleRows,
      },
    );
    final data = (response.data as Map).cast<String, dynamic>();
    if (data['ok'] != true) {
      return AiMappingResponse(
        ok: false,
        error: data['error'] as String? ?? 'No se pudo obtener un mapeo.',
      );
    }
    final mappingJson =
        (data['mapping'] as Map?)?.cast<String, dynamic>() ?? {};
    final mapping = mappingJson.map(
      (campo, valor) => MapEntry(
        campo,
        AiColumnMapping.fromJson((valor as Map).cast<String, dynamic>()),
      ),
    );
    final advertencias = (data['advertencias'] as List?)
        ?.map((e) => e.toString())
        .toList();
    return AiMappingResponse(
      ok: true,
      mapping: mapping,
      advertencias: advertencias,
    );
  }
}
