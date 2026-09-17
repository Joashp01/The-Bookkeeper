import 'package:equatable/equatable.dart';

import 'book.dart';

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
