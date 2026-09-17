import 'package:equatable/equatable.dart';

import '../../domain/models/book.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchTooShort extends SearchState {
  const SearchTooShort(this.minLength);

  final int minLength;

  @override
  List<Object?> get props => [minLength];
}


class SearchUnsupportedQuery extends SearchState {
  const SearchUnsupportedQuery(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}

class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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

  final bool isOffline;

  @override
  List<Object?> get props => [books, hasMore, isLoadingMore, isOffline];
}
