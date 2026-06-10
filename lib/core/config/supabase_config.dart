/// Configuración de Supabase inyectada en build time (AG-CORE-004: las
/// claves nunca van en el código):
///
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///             --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Sin estas variables la app funciona igual (Demo y operación local);
/// solo se deshabilitan activación remota, solicitudes y sync.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get configurado => url.isNotEmpty && anonKey.isNotEmpty;
}
