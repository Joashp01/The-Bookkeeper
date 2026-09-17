/// Data-layer exceptions.
///
/// The data source throws these on I/O or decoding problems; the repository is
/// the single place that catches them and translates each into a typed
/// [Failure] (see `search_repository_impl.dart`). Keeping the two concerns
/// separate is what lets the repository handle every error path explicitly
/// instead of swallowing exceptions.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server responded with a non-success status code.
class ServerException extends AppException {
  const ServerException(this.statusCode)
      : super('Server responded with status $statusCode');

  final int statusCode;
}

/// The response body could not be decoded into the expected shape.
class ParsingException extends AppException {
  const ParsingException(super.message);
}

/// A local persistence (SQL) operation failed.
///
/// The data layer wraps the underlying `DatabaseException` in this typed form so
/// the layers above catch a domain error explicitly, without importing sqflite.
class CacheException extends AppException {
  const CacheException(super.message);
}
