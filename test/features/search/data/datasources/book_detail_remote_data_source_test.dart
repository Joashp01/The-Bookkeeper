import 'dart:convert';

import 'package:bookshelf/core/error/exceptions.dart';
import 'package:bookshelf/features/search/data/datasources/book_detail_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  late MockHttpClient client;
  late BookDetailRemoteDataSource dataSource;

  setUp(() {
    client = MockHttpClient();
    dataSource = BookDetailRemoteDataSourceImpl(client: client);
  });

  test('requests the works endpoint for the given id', () async {
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response(jsonEncode(<String, dynamic>{'title': 'Dune'}), 200),
    );

    await dataSource.fetchWork('OL1W');

    final captured =
        verify(() => client.get(captureAny())).captured.single as Uri;
    expect(captured.host, 'openlibrary.org');
    expect(captured.path, '/works/OL1W.json');
  });

  test('non-200 response throws ServerException', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('nope', 404));

    expect(
      () => dataSource.fetchWork('OL1W'),
      throwsA(isA<ServerException>()),
    );
  });

  test('a non-object JSON body throws ParsingException', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(jsonEncode(<int>[1]), 200));

    expect(
      () => dataSource.fetchWork('OL1W'),
      throwsA(isA<ParsingException>()),
    );
  });
}
