import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'failure.dart';

Failure mapErrorToFailure(Object error) {
  return switch (error) {
    ServerException(:final statusCode, :final message) => ServerFailure(
      message,
      statusCode: statusCode,
    ),
    ParsingException(:final message) => ParsingFailure(message),
    CacheException(:final message) => CacheFailure(message),
    FormatException(:final message) => ParsingFailure(
      'Malformed response: $message',
    ),
    http.ClientException(:final message) => NetworkFailure(message),
    _ => throw error,
  };
}
