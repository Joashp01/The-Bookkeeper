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

    test('maps a 5xx ServerFailure to "service is having trouble" copy', () {
      final message =
          messageForFailure(const ServerFailure('boom', statusCode: 503));

      expect(message.toLowerCase(), contains('having trouble'));
      expect(message, isNot(contains('boom')));
      expect(message, isNot(contains('503')));
    });

    test('maps a 4xx ServerFailure to distinct, input-focused copy', () {
      final client =
          messageForFailure(const ServerFailure('bad request', statusCode: 400));
      final server =
          messageForFailure(const ServerFailure('down', statusCode: 500));

      // A 4xx is the request's fault, not the service's — different guidance.
      expect(client, isNot(equals(server)));
      expect(client.toLowerCase(), isNot(contains('having trouble')));
      expect(client, isNot(contains('400')));
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
