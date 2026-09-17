sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException(this.statusCode)
    : super('Server responded with status $statusCode');

  final int statusCode;
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
