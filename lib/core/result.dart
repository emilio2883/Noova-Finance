/// Lightweight Result type (no external dependency) for explicit error handling.
/// Use with Riverpod: repos return `Result<T, String>`; UI maps Err -> friendly
/// ErrorState. See specs/premium/phase5.md for the migration plan.
sealed class Result<T, E> {
  const Result();
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E error;
  const Err(this.error);
}

extension ResultX<T, E> on Result<T, E> {
  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;
  T? get valueOrNull => this is Ok<T, E> ? (this as Ok<T, E>).value : null;
  E? get errorOrNull => this is Err<T, E> ? (this as Err<T, E>).error : null;

  R fold<R>(R Function(T value) onOk, R Function(E error) onErr) {
    final self = this;
    return self is Ok<T, E> ? onOk(self.value) : onErr((self as Err<T, E>).error);
  }
}

/// Runs [body] capturing any thrown error into an [Err].
Future<Result<T, Object>> runCatching<T>(Future<T> Function() body) async {
  try {
    return Ok<T, Object>(await body());
  } catch (e) {
    return Err<T, Object>(e);
  }
}
