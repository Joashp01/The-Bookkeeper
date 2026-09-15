import 'package:equatable/equatable.dart';

import 'book.dart';

/// Immutable result of a single search request: the page of books plus the
/// total match count reported by Open Library.
///
/// [numFound] is what pagination in the presentation layer uses to decide
/// whether more pages exist; the repository does not make that decision itself.
/// [isOffline] is true when the results were served from the local cache after a
/// failed network request (F4), so the UI can show an offline indicator.
class SearchResult extends Equatable {
  const SearchResult({
    required this.books,
    required this.numFound,
    required this.page,
    this.isOffline = false,
  });

  final List<Book> books;
  final int numFound;
  final int page;
  final bool isOffline;

  bool get isEmpty => books.isEmpty;

  @override
  List<Object?> get props => [books, numFound, page, isOffline];
}
