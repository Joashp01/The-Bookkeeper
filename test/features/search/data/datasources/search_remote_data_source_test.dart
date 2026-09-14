import 'dart:convert';

import 'package:bookshelf/core/error/exceptions.dart';
import 'package:bookshelf/features/search/data/datasources/search_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  late MockHttpClient client;
  late SearchRemoteDataSource dataSource;

  setUp(() {
    client = MockHttpClient();
    dataSource = SearchRemoteDataSourceImpl(client: client);
  });

  const emptyBody = <String, dynamic>{'numFound': 0, 'docs': <dynamic>[]};

  test('builds the Open Library search URL with q and page', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(jsonEncode(emptyBody), 200));

    await dataSource.search(query: 'dune', page: 3);

    final captured =
        verify(() => client.get(captureAny())).captured.single as Uri;
    expect(captured.scheme, 'https');
    expect(captured.host, 'openlibrary.org');
    expect(captured.path, '/search.json');
    expect(captured.queryParameters['q'], 'dune');
    expect(captured.queryParameters['page'], '3');
  });

  test('non-200 response throws ServerException with the status code',
      () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('nope', 404));

    expect(
      () => dataSource.search(query: 'dune', page: 1),
      throwsA(isA<ServerException>()
          .having((e) => e.statusCode, 'statusCode', 404)),
    );
  });

  test('a JSON body that is not an object throws ParsingException', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(jsonEncode(<int>[1, 2]), 200));

    expect(
      () => dataSource.search(query: 'dune', page: 1),
      throwsA(isA<ParsingException>()),
    );
  });
}
