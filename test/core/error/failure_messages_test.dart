import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/failure_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('messageForFailure', () {
    test('maps NetworkFailure to friendly offline copy', () {
      final message = messageForFailure(const NetworkFailure('SocketException'));

      expect(message.toLowerCase(), contains('offline'));
      // Never leaks the raw technical detail.
      expect(message, isNot(contains('SocketException')));
    });

    test('maps ServerFailure to friendly copy, hiding the raw message', () {
      final message =
          messageForFailure(const ServerFailure('boom', statusCode: 503));

      expect(message, isNotEmpty);
      expect(message, isNot(contains('boom')));
      expect(message, isNot(contains('503')));
    });

    test('maps ParsingFailure to friendly copy', () {
      final message = messageForFailure(const ParsingFailure('bad json'));

      expect(message, isNotEmpty);
      expect(message, isNot(contains('bad json')));
    });

    test('maps CacheFailure to friendly copy', () {
      final message = messageForFailure(const CacheFailure('sql error'));

      expect(message, isNotEmpty);
      expect(message, isNot(contains('sql error')));
    });
  });
}
