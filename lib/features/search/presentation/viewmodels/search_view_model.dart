import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failure_messages.dart';
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
    int minQueryLength = 3,
  })  : _repository = repository,
        _debounceDuration = debounceDuration,
        _minQueryLength = minQueryLength;

  final SearchRepository _repository;
  final Duration _debounceDuration;

  /// Shortest query the remote API accepts. Below this the search endpoint
  /// responds 422, so we never fire the request and prompt the user instead.
  final int _minQueryLength;

  Timer? _debounce;
  String _query = '';
  int _page = 1;

  // Monotonic id for the "current intent". Every request captures the value
  // live at dispatch; when its response arrives we drop it if the generation has
  // since moved on (a newer query, or the query was cleared). This stops a slow
  // in-flight response from clobbering fresher state.
  int _generation = 0;
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

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      _generation++;
      _reset();
      _setState(const SearchInitial());
      return;
    }

    if (trimmed.length < _minQueryLength) {
      _generation++;
      _reset();
      _setState(SearchTooShort(_minQueryLength));
      return;
    }

    _debounce = Timer(_debounceDuration, () => _runInitialSearch(trimmed));
  }

  Future<void> _runInitialSearch(String term) async {
    _resetPaging();
    final generation = ++_generation;
    _setState(const SearchLoading());

    final result = await _repository.search(query: term, page: _page);
    if (generation != _generation) {
      return; // A newer query (or a clear) superseded this request.
    }
    result.when(
      success: (page) {
        _numFound = page.numFound;
        _isOffline = page.isOffline;
        _books
          ..clear()
          ..addAll(page.books);
        _setState(_books.isEmpty ? const SearchEmpty() : _resultsState());
      },
      failure: (failure) => _setState(SearchError(messageForFailure(failure))),
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

    final generation = _generation;
    _isLoadingMore = true;
    _setState(_resultsState());

    final nextPage = _page + 1;
    final result = await _repository.search(query: _query.trim(), page: nextPage);
    if (generation != _generation) {
      return; // A new search started while this page was loading; discard it.
    }
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
