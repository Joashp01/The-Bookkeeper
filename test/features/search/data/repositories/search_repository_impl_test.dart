import 'dart:convert';

import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/core/network/connectivity_checker.dart';
import 'package:bookshelf/features/search/data/datasources/search_cache_data_source.dart';
import 'package:bookshelf/features/search/data/datasources/search_remote_data_source.dart';
import 'package:bookshelf/features/search/data/repositories/search_repository_impl.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class _FakeCache implements SearchCacheDataSource {
  final Map<String, CachedSearch> _store = {};
  int saveCount = 0;

  @override
  Future<void> save({
    required String query,
    required int page,
    required int numFound,
    required List<Book> books,
  }) async {
    saveCount++;
    _store['$query|$page'] = CachedSearch(numFound: numFound, books: books);
  }

  @override
  Future<CachedSearch?> read({required String query, required int page}) async =>
      _store['$query|$page'];
}

class _FakeConnectivity implements ConnectivityChecker {
  bool online = true;

  @override
  Future<bool> hasConnection() async => online;

  @override
  Stream<bool> get onConnectivityChanged => Stream<bool>.value(online);
}

void main() {
  setUpAll(() => registerFallbackValue(Uri()));

  late MockHttpClient client;
  late _FakeCache cache;
  late _FakeConnectivity connectivity;
  late SearchRepository repository;

  setUp(() {
    client = MockHttpClient();
    cache = _FakeCache();
    connectivity = _FakeConnectivity();
    repository = SearchRepositoryImpl(
      remoteDataSource: SearchRemoteDataSourceImpl(client: client),
      cache: cache,
      connectivity: connectivity,
    );
  });

  void stubResponse(String body, int statusCode) {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(body, statusCode));
  }

  const successBody = <String, dynamic>{
    'numFound': 2,
    'docs': <dynamic>[
      <String, dynamic>{
        'key': '/works/OL1W',
        'title': 'Dune',
        'author_name': <String>['Frank Herbert'],
        'cover_i': 111,
        'first_publish_year': 1965,
      },
      <String, dynamic>{
        'key': '/works/OL2W',
        'title': 'Dune Messiah',
      },
    ],
  };

  group('SearchRepositoryImpl.search', () {
    test('successful response maps to a page of books and numFound', () async {
      stubResponse(jsonEncode(successBody), 200);

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<Success<SearchResult>>());
      final value = (result as Success<SearchResult>).value;
      expect(value.numFound, 2);
      expect(value.page, 1);
      expect(value.books, hasLength(2));
      expect(value.books.first.title, 'Dune');
      expect(value.isOffline, isFalse);
      expect(value.books[1].coverUrl, isNull);
    });

    test('HTTP error response returns a ServerFailure with the status code',
        () async {
      stubResponse('Internal Server Error', 500);

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<FailureResult<SearchResult>>());
      final failure = (result as FailureResult<SearchResult>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('malformed JSON returns a ParsingFailure (no crash)', () async {
      stubResponse('this is { not json', 200);

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<FailureResult<SearchResult>>());
      expect(
        (result as FailureResult<SearchResult>).failure,
        isA<ParsingFailure>(),
      );
    });

    test('unexpected JSON shape (not an object) returns a ParsingFailure',
        () async {
      stubResponse(jsonEncode(<int>[1, 2, 3]), 200);

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<FailureResult<SearchResult>>());
      expect(
        (result as FailureResult<SearchResult>).failure,
        isA<ParsingFailure>(),
      );
    });

    test('empty result set returns an empty (non-error) page', () async {
      stubResponse(
        jsonEncode(<String, dynamic>{'numFound': 0, 'docs': <dynamic>[]}),
        200,
      );

      final result = await repository.search(query: 'zzzznotfound', page: 1);

      expect(result, isA<Success<SearchResult>>());
      final value = (result as Success<SearchResult>).value;
      expect(value.isEmpty, isTrue);
      expect(value.numFound, 0);
    });

    test('a successful response is written to the cache', () async {
      stubResponse(jsonEncode(successBody), 200);

      await repository.search(query: 'dune', page: 1);

      expect(cache.saveCount, 1);
    });
  });

  group('offline behaviour (F4)', () {
    Future<void> primeCache() async {
      stubResponse(jsonEncode(successBody), 200);
      await repository.search(query: 'dune', page: 1);
    }

    test('offline with cached results serves the cache with the offline flag',
        () async {
      await primeCache();
      connectivity.online = false;
      when(() => client.get(any()))
          .thenThrow(http.ClientException('offline'));

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<Success<SearchResult>>());
      final value = (result as Success<SearchResult>).value;
      expect(value.isOffline, isTrue);
      expect(value.books, hasLength(2));
    });

    test('offline with no cache returns a NetworkFailure', () async {
      connectivity.online = false;
      when(() => client.get(any()))
          .thenThrow(http.ClientException('offline'));

      final result = await repository.search(query: 'never-run', page: 1);

      expect(
        (result as FailureResult<SearchResult>).failure,
        isA<NetworkFailure>(),
      );
    });

    test('a transient failure while online does not serve the cache', () async {
      await primeCache();
      connectivity.online = true;
      when(() => client.get(any())).thenThrow(http.ClientException('flaky'));

      final result = await repository.search(query: 'dune', page: 1);

      expect(result, isA<FailureResult<SearchResult>>());
      expect(
        (result as FailureResult<SearchResult>).failure,
        isA<NetworkFailure>(),
      );
    });
  });
}
