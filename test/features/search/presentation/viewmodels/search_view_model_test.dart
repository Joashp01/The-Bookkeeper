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

Book _book(String id) =>
    Book(key: '/works/$id', title: id, authorNames: const ['A'], firstPublishYear: 2000);

/// Fires the debounce timer and resolves the async search that follows.
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
              SearchResult(books: [_book('a'), _book('b')], numFound: 2, page: page),
            );
      final vm = SearchViewModel(repository: repo, debounceDuration: Duration.zero);

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
      final vm = SearchViewModel(repository: repo, debounceDuration: Duration.zero);

      vm.onQueryChanged('zzz');
      _settle(async);

      expect(vm.state, isA<SearchEmpty>());
    });
  });

  test('a failure transitions to SearchError carrying the message', () {
    fakeAsync((async) {
      final repo = _FakeRepo()
        ..responder = (query, page) =>
            const FailureResult(ServerFailure('boom', statusCode: 500));
      final vm = SearchViewModel(repository: repo, debounceDuration: Duration.zero);

      vm.onQueryChanged('dune');
      _settle(async);

      expect(vm.state, isA<SearchError>());
      expect((vm.state as SearchError).message, 'boom');
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
      final vm = SearchViewModel(repository: repo, debounceDuration: Duration.zero);

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
      final vm = SearchViewModel(repository: repo, debounceDuration: Duration.zero);

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
}
