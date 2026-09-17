import 'failure.dart';

String messageForFailure(Failure failure) {
  return switch (failure) {
    NetworkFailure() =>
      "You're offline. Check your internet connection and try again.",
    ServerFailure(:final statusCode)
        when statusCode != null && statusCode >= 400 && statusCode < 500 =>
      "We couldn't complete that request. Please check the details and try "
          'again.',
    ServerFailure() =>
      'The book service is having trouble right now. Please try again in a '
          'little while.',
    ParsingFailure() =>
      'We received an unexpected response. Please try again in a moment.',
    CacheFailure() => "We couldn't update your saved books. Please try again.",
  };
}
