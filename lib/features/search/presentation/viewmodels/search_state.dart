import 'package:equatable/equatable.dart';

import '../../domain/models/book.dart';

/// The four visible search states the brief requires — loading, results, empty
/// and error — plus an [SearchInitial] resting state before the first query.
///
/// Modelled as a sealed hierarchy so the UI switches over it exhaustively and
/// each state renders distinctly.
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// No query entered yet.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// A first-page request is in flight.
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// The query completed but matched nothing.
class SearchEmpty extends SearchState {
  const SearchEmpty();
}

/// The request failed; [message] is friendly, user-safe copy to display.
class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// One or more results are available.
///
/// [hasMore] drives infinite scroll; [isLoadingMore] shows a footer spinner
/// while the next page loads without replacing the current list.
class SearchResults extends SearchState {
  const SearchResults({
    required this.books,
    required this.hasMore,
    this.isLoadingMore = false,
    this.isOffline = false,
  });

  final List<Book> books;
  final bool hasMore;
  final bool isLoadingMore;

  /// True when these results came from the local cache (F4).
  final bool isOffline;

  @override
  List<Object?> get props => [books, hasMore, isLoadingMore, isOffline];
}
