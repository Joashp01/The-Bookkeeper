import 'failure.dart';

/// Maps a domain [Failure] to friendly, non-technical copy that is safe to show
/// the user.
///
/// The raw `Failure.message` stays technical (useful for logs); this is the
/// single place the app decides what a user actually reads. Keeping it pure and
/// separate from the widgets makes the copy unit-testable and consistent across
/// every screen. Exhaustive over the sealed [Failure] hierarchy, so a new
/// failure type is a compile error here until its copy is defined — the user
/// never sees a raw exception string by accident.
String messageForFailure(Failure failure) {
  return switch (failure) {
    NetworkFailure() =>
      "You're offline. Check your internet connection and try again.",
    ServerFailure() =>
      'The book service is having trouble right now. Please try again in a '
          'little while.',
    ParsingFailure() =>
      'We received an unexpected response. Please try again in a moment.',
    CacheFailure() => "We couldn't read your saved data. Please try again.",
  };
}
