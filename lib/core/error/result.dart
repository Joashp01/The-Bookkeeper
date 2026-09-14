import 'failure.dart';

/// A lightweight success-or-failure wrapper used by the domain/data layers so
/// that error handling stays explicit at every call site rather than relying on
/// thrown exceptions crossing layer boundaries.
sealed class Result<T> {
  const Result();

  /// Fold both branches into a single value.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.value),
      FailureResult<T>() => failure(self.failure),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
