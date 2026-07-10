/// Metadatos del paquete de respaldo (RF-RES-01), almacenados como
/// `manifest.json` dentro del ZIP.
class BackupManifest {
  const BackupManifest({
    required this.schemaVersion,
    required this.appVersion,
    required this.fechaCreacion,
    required this.negocioId,
    required this.negocioNombre,
  });

  /// Versión de [AppDatabase.schemaVersion] con la que se generó el respaldo.
  final int schemaVersion;

  /// `package_info_plus` -- versión de la app que generó el respaldo.
  final String appVersion;
  final DateTime fechaCreacion;
  final String negocioId;
  final String negocioNombre;

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      schemaVersion: json['schemaVersion'] as int,
      appVersion: json['appVersion'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      negocioId: json['negocioId'] as String,
      negocioNombre: json['negocioNombre'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'negocioId': negocioId,
    'negocioNombre': negocioNombre,
  };
}
