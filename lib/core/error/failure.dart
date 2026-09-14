import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced by the domain/data layers.
///
/// Using a sealed hierarchy forces callers to handle each failure explicitly
/// (the brief penalises empty catch blocks): a `switch` over [Failure] is
/// exhaustive at compile time.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The remote API returned a non-success status code.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// The request could not be completed because the device appears to be offline.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// The response was received but could not be parsed into the expected shape.
class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

/// A local persistence (SQL) operation failed.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
