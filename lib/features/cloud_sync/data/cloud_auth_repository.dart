import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sesión del PROPIETARIO del negocio en Supabase Auth -- independiente del
/// login local de empleados (PBKDF2, ver features/auth). Es opcional: la app
/// funciona 100% local sin esta cuenta; iniciar sesión acá solo activa el
/// SyncEngine (ver core/sync/sync_provider.dart).
///
/// OJO al consumir estos providers: tocan `Supabase.instance`, que nunca se
/// inicializa si `SupabaseConfig.configurado` es false. Nunca watchear desde
/// un widget que se construye siempre -- solo desde la pantalla de
/// vinculación con la nube (ya gateada por `configurado`) o desde
/// syncEngineProvider (que chequea `configurado` antes de leer esto).
class CloudAuthRepository {
  CloudAuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}

final cloudAuthRepositoryProvider = Provider<CloudAuthRepository>((ref) {
  return CloudAuthRepository(Supabase.instance.client);
});

final cloudAuthStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(cloudAuthRepositoryProvider).authStateChanges;
});

final cloudCurrentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(cloudAuthStateProvider).value;
  return authState?.session?.user ??
      ref.watch(cloudAuthRepositoryProvider).currentUser;
});
