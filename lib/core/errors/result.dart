/// Resultado de operaciones de la capa domain: éxito con valor o fallo tipado.
///
/// Los repositorios y casos de uso devuelven [Result] en lugar de lanzar
/// excepciones hacia la UI.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.fail(Failure failure) = Fail<T>;

  bool get isOk => this is Ok<T>;

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) fail,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Fail(:final failure) => fail(failure),
    };
  }

  /// Valor en éxito, o `null` en fallo.
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Fail() => null,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Fail<T> extends Result<T> {
  const Fail(this.failure);
  final Failure failure;
}

/// Fallo de dominio con mensaje presentable al usuario.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Regla de negocio violada (ej. RN-01: vender sin caja abierta).
final class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure(super.message, {this.rule});

  /// Identificador de la regla (ej. 'RN-01') para auditoría/tests.
  final String? rule;
}

/// Error de validación de entrada (formularios).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de persistencia local (SQLite/Drift).
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Error de red o de Supabase (licencias, sync).
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Acceso denegado por rol o sesión inválida.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Licencia inválida, suspendida o vencida (RN-15).
final class LicenseFailure extends Failure {
  const LicenseFailure(super.message);
}
