import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../domain/models/book.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_state.dart';

class SearchViewModel extends ChangeNotifier {
  // ignore_for_file: prefer_initializing_formals
  SearchViewModel({
    required SearchRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 400),
    int minQueryLength = 3,
  }) : _repository = repository,
       _debounceDuration = debounceDuration,
       _minQueryLength = minQueryLength;

  final SearchRepository _repository;
  final Duration _debounceDuration;

  final int _minQueryLength;

  Timer? _debounce;
  String _query = '';
  int _page = 1;

  int _generation = 0;
  int _numFound = 0;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  final List<Book> _books = [];

  SearchState _state = const SearchInitial();
  SearchState get state => _state;
  String get query => _query;

  bool get _hasMore => _books.length < _numFound;

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
      return;
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
      failure: (failure) => _setState(_stateForFailure(failure)),
    );
  }

  /// Turns a search [Failure] into the right view state. A 4xx means the query
  /// itself was refused (Open Library rejects bare stop-words like "the" and
  /// other unsearchable terms) — retrying the same text can't help, so we show a
  /// calm refine-your-search prompt instead of the error card. Everything else
  /// is a genuine error.
  SearchState _stateForFailure(Failure failure) {
    if (failure is ServerFailure &&
        failure.statusCode != null &&
        failure.statusCode! >= 400 &&
        failure.statusCode! < 500) {
      return const SearchUnsupportedQuery(
        "We couldn't search for that. Try a more specific title, author, or "
        'subject.',
      );
    }
    return SearchError(messageForFailure(failure));
  }

  Future<void> loadNextPage() async {
    final current = _state;
    if (current is! SearchResults || !current.hasMore || _isLoadingMore) {
      return;
    }

    final generation = _generation;
    _isLoadingMore = true;
    _setState(_resultsState());

    final nextPage = _page + 1;
    final result = await _repository.search(
      query: _query.trim(),
      page: nextPage,
    );
    if (generation != _generation) {
      return;
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
