import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/book.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_state.dart';

/// Presentation-layer state holder for the search screen.
///
/// Owns the debounce, pagination and state-machine logic so the widget stays
/// dumb. It depends only on the [SearchRepository] abstraction, injected via DI.
class SearchViewModel extends ChangeNotifier {
  // Named parameters cannot be private, so `this._field` initializing formals
  // are impossible here; assigning in the initializer list is the idiomatic
  // alternative (hence the lint suppression).
  // ignore_for_file: prefer_initializing_formals
  SearchViewModel({
    required SearchRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 400),
  })  : _repository = repository,
        _debounceDuration = debounceDuration;

  final SearchRepository _repository;
  final Duration _debounceDuration;

  Timer? _debounce;
  String _query = '';
  int _page = 1;
  int _numFound = 0;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  final List<Book> _books = [];

  SearchState _state = const SearchInitial();
  SearchState get state => _state;
  String get query => _query;

  bool get _hasMore => _books.length < _numFound;

  /// Called on every keystroke. Debounces so only the last value in a burst
  /// fires a request. An empty query resets to the initial state immediately.
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      _reset();
      _setState(const SearchInitial());
      return;
    }

    _debounce = Timer(_debounceDuration, () => _runInitialSearch(value.trim()));
  }

  Future<void> _runInitialSearch(String term) async {
    _resetPaging();
    _setState(const SearchLoading());

    final result = await _repository.search(query: term, page: _page);
    result.when(
      success: (page) {
        _numFound = page.numFound;
        _isOffline = page.isOffline;
        _books
          ..clear()
          ..addAll(page.books);
        _setState(_books.isEmpty ? const SearchEmpty() : _resultsState());
      },
      failure: (failure) => _setState(SearchError(failure.message)),
    );
  }

  /// Loads and appends the next page. No-op unless results are shown and more
  /// pages exist. A pagination failure keeps the existing list rather than
  /// wiping it.
  Future<void> loadNextPage() async {
    final current = _state;
    if (current is! SearchResults || !current.hasMore || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    _setState(_resultsState());

    final nextPage = _page + 1;
    final result = await _repository.search(query: _query.trim(), page: nextPage);
    _isLoadingMore = false;

    result.when(
      success: (page) {
        _page = nextPage;
        _numFound = page.numFound;
        _isOffline = page.isOffline;
        _books.addAll(page.books);
        _setState(_resultsState());
      },
      failure: (_) => _setState(_resultsState()),
    );
  }

  /// Re-runs the current query from the first page (used by the error retry).
  Future<void> retry() async {
    if (_query.trim().isEmpty) {
      return;
    }
    await _runInitialSearch(_query.trim());
  }

  SearchResults _resultsState() => SearchResults(
        books: List.unmodifiable(_books),
        hasMore: _hasMore,
        isLoadingMore: _isLoadingMore,
        isOffline: _isOffline,
      );

  void _resetPaging() {
    _page = 1;
    _numFound = 0;
    _isLoadingMore = false;
    _isOffline = false;
    _books.clear();
  }

  void _reset() {
    _debounce?.cancel();
    _resetPaging();
  }

  void _setState(SearchState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
