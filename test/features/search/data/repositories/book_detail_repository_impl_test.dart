import 'dart:convert';

import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/features/search/data/datasources/book_detail_remote_data_source.dart';
import 'package:bookshelf/features/search/data/repositories/book_detail_repository_impl.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/book_detail.dart';
import 'package:bookshelf/features/search/domain/repositories/book_detail_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  late MockHttpClient client;
  late BookDetailRepository repository;

  setUp(() {
    client = MockHttpClient();
    repository = BookDetailRepositoryImpl(
      remoteDataSource: BookDetailRemoteDataSourceImpl(client: client),
    );
  });

  const book = Book(
    key: '/works/OL1W',
    title: 'Dune',
    authorNames: ['Frank Herbert'],
    coverId: 111,
    firstPublishYear: 1965,
  );

  void stubResponse(Object body, int statusCode) {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(jsonEncode(body), statusCode));
  }

  test('maps the work and threads author, year and fallback cover', () async {
    stubResponse(<String, dynamic>{
      'key': '/works/OL1W',
      'title': 'Dune',
      'description': 'A desert epic.',
      'subjects': <String>['Science Fiction'],
    }, 200);

    final result = await repository.getDetail(book);

    expect(result, isA<Success<BookDetail>>());
    final detail = (result as Success<BookDetail>).value;
    expect(detail.workId, 'OL1W');
    expect(detail.title, 'Dune');
    expect(detail.authorNames, ['Frank Herbert']);
    expect(detail.firstPublishYear, 1965);
    expect(detail.description, 'A desert epic.');
    expect(detail.subjects, ['Science Fiction']);
    // Work had no cover, so the search result's cover is used.
    expect(detail.coverId, 111);
  });

  test('handles description delivered as an object with a value key', () async {
    stubResponse(<String, dynamic>{
      'title': 'Dune',
      'description': <String, dynamic>{'type': '/type/text', 'value': 'Nested.'},
    }, 200);

    final result = await repository.getDetail(book);

    final detail = (result as Success<BookDetail>).value;
    expect(detail.description, 'Nested.');
  });

  test('HTTP error returns a ServerFailure', () async {
    stubResponse('error', 500);

    final result = await repository.getDetail(book);

    expect(result, isA<FailureResult<BookDetail>>());
    expect(
      (result as FailureResult<BookDetail>).failure,
      isA<ServerFailure>(),
    );
  });

  test('transport failure returns a NetworkFailure', () async {
    when(() => client.get(any()))
        .thenThrow(http.ClientException('offline'));

    final result = await repository.getDetail(book);

    expect(
      (result as FailureResult<BookDetail>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('an empty key fails fast without hitting the network', () async {
    const keyless = Book(key: '', title: 'Dune', authorNames: ['Frank Herbert']);

    final result = await repository.getDetail(keyless);

    expect(result, isA<FailureResult<BookDetail>>());
    final failure = (result as FailureResult<BookDetail>).failure;
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 404);
    // No round trip is wasted on a request we know would 404.
    verifyNever(() => client.get(any()));
  });
}
