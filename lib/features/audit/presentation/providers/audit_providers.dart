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

/// Filtros de la pantalla de auditoría. Se descartan al salir de la pantalla
/// (así al volver no queda un filtro olvidado).
final auditoriaFiltroProvider =
    NotifierProvider.autoDispose<AuditoriaFiltroController, AuditoriaFiltro>(
      AuditoriaFiltroController.new,
    );

class AuditoriaFiltroController extends Notifier<AuditoriaFiltro> {
  @override
  AuditoriaFiltro build() => const AuditoriaFiltro();

  /// Aplica un cambio de filtro y vuelve a la primera página (un filtro
  /// nuevo no debe arrastrar el "cargar más" del anterior).
  void actualizar(AuditoriaFiltro Function(AuditoriaFiltro actual) update) {
    state = update(state);
    ref.read(limiteAuditoriaProvider.notifier).reiniciar();
  }
}

/// Cuántos registros se piden: empieza en una página y "Cargar más" suma
/// otra.
final limiteAuditoriaProvider =
    NotifierProvider.autoDispose<LimiteAuditoriaController, int>(
      LimiteAuditoriaController.new,
    );

class LimiteAuditoriaController extends Notifier<int> {
  @override
  int build() => limitePorDefectoAuditoria;

  void cargarMas() => state += limitePorDefectoAuditoria;

  void reiniciar() => state = limitePorDefectoAuditoria;
}

/// Registros de auditoría según el filtro activo, más reciente primero y
/// hasta el límite actual.
final registrosAuditoriaProvider =
    StreamProvider.autoDispose<List<RegistroAuditoria>>((ref) {
      final filtro = ref.watch(auditoriaFiltroProvider);
      final limite = ref.watch(limiteAuditoriaProvider);
      return ref
          .watch(auditRepositoryProvider)
          .watchRegistros(filtro, limite: limite);
    });

final modulosAuditoriaProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return ref.watch(auditRepositoryProvider).listarModulos();
});

final accionesAuditoriaProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return ref.watch(auditRepositoryProvider).listarAcciones();
});

final usuariosAuditoriaProvider =
    FutureProvider.autoDispose<List<UsuarioFiltro>>((ref) {
      return ref.watch(auditRepositoryProvider).listarUsuarios();
    });
