import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/audit_local_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/entities/registro_auditoria.dart';
import '../../domain/repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(
    AuditLocalDatasource(ref.watch(appDatabaseProvider)),
  );
});

final auditoriaFiltroProvider =
    NotifierProvider<AuditoriaFiltroController, AuditoriaFiltro>(
      AuditoriaFiltroController.new,
    );

class AuditoriaFiltroController extends Notifier<AuditoriaFiltro> {
  @override
  AuditoriaFiltro build() => const AuditoriaFiltro();

  void actualizar(AuditoriaFiltro Function(AuditoriaFiltro actual) update) {
    state = update(state);
  }
}

/// Registros de auditoría según el filtro activo, más reciente primero.
final registrosAuditoriaProvider = StreamProvider<List<RegistroAuditoria>>((
  ref,
) {
  final filtro = ref.watch(auditoriaFiltroProvider);
  return ref.watch(auditRepositoryProvider).watchRegistros(filtro);
});

final modulosAuditoriaProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(auditRepositoryProvider).listarModulos();
});

final accionesAuditoriaProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(auditRepositoryProvider).listarAcciones();
});

final usuariosAuditoriaProvider = FutureProvider<List<UsuarioFiltro>>((ref) {
  return ref.watch(auditRepositoryProvider).listarUsuarios();
});
