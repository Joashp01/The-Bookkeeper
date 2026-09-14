import 'package:http/http.dart' as http;

import 'exceptions.dart';
import 'failure.dart';

/// Translates a known data-layer error into a typed [Failure].
///
/// Shared by the repositories so the exception → failure policy lives in one
/// place. Anything not recognised is rethrown rather than swallowed, so genuine
/// programming errors surface instead of being masked by a generic failure.
Failure mapErrorToFailure(Object error) {
  return switch (error) {
    ServerException(:final statusCode, :final message) =>
      ServerFailure(message, statusCode: statusCode),
    ParsingException(:final message) => ParsingFailure(message),
    FormatException(:final message) =>
      ParsingFailure('Malformed response: $message'),
    http.ClientException(:final message) => NetworkFailure(message),
    _ => throw error,
  };
}
