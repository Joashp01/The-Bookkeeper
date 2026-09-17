import 'dart:async';

import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/search_result.dart';
import 'package:bookshelf/features/search/domain/repositories/search_repository.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/search_state.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/search_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements SearchRepository {
  int callCount = 0;
  final List<int> requestedPages = [];
  final List<String> requestedQueries = [];

  Result<SearchResult> Function(String query, int page) responder =
      (query, page) =>
          Success(SearchResult(books: const [], numFound: 0, page: page));

  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) async {
    callCount++;
    requestedPages.add(page);
    requestedQueries.add(query);
    return responder(query, page);
  }
}

Book _book(String id) => Book(
  key: '/works/$id',
  title: id,
  authorNames: const ['A'],
  firstPublishYear: 2000,
);

void _settle(FakeAsync async) {
  async.flushTimers();
  async.flushMicrotasks();
}

void main() {
  test('initial state is SearchInitial', () {
    final vm = SearchViewModel(repository: _FakeRepo());
    expect(vm.state, isA<SearchInitial>());
  });

  test('an empty/whitespace query resets to initial and skips the request', () {
    final repo = _FakeRepo();
    final vm = SearchViewModel(repository: repo);

    vm.onQueryChanged('   ');

    expect(vm.state, isA<SearchInitial>());
    expect(repo.callCount, 0);
  });

  test(
    'a query shorter than the minimum shows a hint and skips the request',
    () {
      fakeAsync((async) {
        final repo = _FakeRepo();
        final vm = SearchViewModel(
          repository: repo,
          debounceDuration: Duration.zero,
        );

        vm.onQueryChanged('lo');
        _settle(async);

        expect(vm.state, isA<SearchTooShort>());
        expect((vm.state as SearchTooShort).minLength, 3);
        expect(
          repo.callCount,
          0,
          reason: 'the API rejects queries under 3 chars',
        );
      });
    },
  );

  test('reaching the minimum length fires the search', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) =>
            Success(SearchResult(books: [_book('a')], numFound: 1, page: page));
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('lo');
      _settle(async);
      expect(repo.callCount, 0);

      vm.onQueryChanged('lor');
      _settle(async);

      expect(repo.callCount, 1);
      expect(vm.state, isA<SearchResults>());
    });
  });

  test('rapid keystrokes are debounced into a single request', () {
    fakeAsync((async) {
      final repo = _FakeRepo();
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: const Duration(milliseconds: 400),
      );

      vm
        ..onQueryChanged('d')
        ..onQueryChanged('du')
        ..onQueryChanged('dune');

      async.elapse(const Duration(milliseconds: 399));
      expect(repo.callCount, 0, reason: 'must not fire before the debounce');

      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();

      expect(repo.callCount, 1);
      expect(repo.requestedQueries.single, 'dune');
    });
  });

  test('a successful search transitions to SearchResults', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) => Success(
          SearchResult(
            books: [_book('a'), _book('b')],
            numFound: 2,
            page: page,
          ),
        );
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('dune');
      _settle(async);

      expect(vm.state, isA<SearchResults>());
      final state = vm.state as SearchResults;
      expect(state.books, hasLength(2));
      expect(state.hasMore, isFalse);
    });
  });

  test('an empty result set transitions to SearchEmpty', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) =>
            Success(SearchResult(books: const [], numFound: 0, page: page));
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('zzz');
      _settle(async);

      expect(vm.state, isA<SearchEmpty>());
    });
  });

  test('a failure transitions to SearchError with friendly copy', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) =>
            const FailureResult(ServerFailure('boom', statusCode: 500));
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('dune');
      _settle(async);

      expect(vm.state, isA<SearchError>());
      final error = vm.state as SearchError;
      expect(error.message, isNot(contains('boom')));
      expect(error.message, isNotEmpty);
    });
  });

  test('a 4xx (rejected query) shows a refine prompt, not the error card', () {
    fakeAsync((async) {
   
      final repo = _FakeRepo()
        ..responder = (query, page) =>
            const FailureResult(ServerFailure('invalid query', statusCode: 422));
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('the');
      _settle(async);

      expect(vm.state, isA<SearchUnsupportedQuery>());
      expect(vm.state, isNot(isA<SearchError>()));
      expect((vm.state as SearchUnsupportedQuery).message, isNotEmpty);
    });
  });

  test('propagates the offline flag from a cached (offline) result', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) => Success(
          SearchResult(
            books: [_book('a')],
            numFound: 1,
            page: page,
            isOffline: true,
          ),
        );
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('dune');
      _settle(async);

      expect((vm.state as SearchResults).isOffline, isTrue);
    });
  });

  test('loadNextPage appends the next page and updates hasMore', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) => Success(
          SearchResult(
            books: [_book('p${page}a'), _book('p${page}b')],
            numFound: 4,
            page: page,
          ),
        );
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('dune');
      _settle(async);
      expect((vm.state as SearchResults).hasMore, isTrue);

      vm.loadNextPage();
      async.flushMicrotasks();

      final state = vm.state as SearchResults;
      expect(state.books, hasLength(4));
      expect(state.hasMore, isFalse);
      expect(repo.requestedPages, [1, 2]);
    });
  });

  test('loadNextPage is a no-op when there are no results yet', () {
    fakeAsync((async) {
      final repo = _FakeRepo();
      final vm = SearchViewModel(repository: repo);

      vm.loadNextPage();
      async.flushMicrotasks();

      expect(repo.callCount, 0);
    });
  });

  test(
    'a slow response for a superseded query does not clobber the newer one',
    () {
      fakeAsync((async) {
        final completers = <String, Completer<Result<SearchResult>>>{};
        final repo = _DeferredRepo(completers);
        final vm = SearchViewModel(
          repository: repo,
          debounceDuration: Duration.zero,
        );

        vm.onQueryChanged('older');
        async.flushTimers();

        vm.onQueryChanged('newer');
        async.flushTimers();
        completers['newer']!.complete(
          Success(SearchResult(books: [_book('newer')], numFound: 1, page: 1)),
        );
        async.flushMicrotasks();
        expect((vm.state as SearchResults).books.single.title, 'newer');

        completers['older']!.complete(
          Success(SearchResult(books: [_book('older')], numFound: 1, page: 1)),
        );
        async.flushMicrotasks();

        expect(
          (vm.state as SearchResults).books.single.title,
          'newer',
          reason: 'the stale response was ignored',
        );
      });
    },
  );

  test('a response arriving after the query is cleared is discarded', () {
    fakeAsync((async) {
      final completers = <String, Completer<Result<SearchResult>>>{};
      final repo = _DeferredRepo(completers);
      final vm = SearchViewModel(
        repository: repo,
        debounceDuration: Duration.zero,
      );

      vm.onQueryChanged('dune');
      async.flushTimers();

      vm.onQueryChanged('');
      completers['dune']!.complete(
        Success(SearchResult(books: [_book('dune')], numFound: 1, page: 1)),
      );
      async.flushMicrotasks();

      expect(
        vm.state,
        isA<SearchInitial>(),
        reason: 'the late response must not resurrect results',
      );
    });
  });
}

class _DeferredRepo implements SearchRepository {
  _DeferredRepo(this.completers);

  final Map<String, Completer<Result<SearchResult>>> completers;

  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) {
    return completers
        .putIfAbsent(query, () => Completer<Result<SearchResult>>())
        .future;
  }
}
