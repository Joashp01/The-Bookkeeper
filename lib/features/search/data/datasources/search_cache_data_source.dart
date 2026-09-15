import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/book.dart';

/// A cached page of search results read back from local storage.
class CachedSearch {
  const CachedSearch({required this.numFound, required this.books});

  final int numFound;
  final List<Book> books;
}

/// Interface for caching the most recent search results locally (F4). Behind an
/// interface so the repository can be tested without a database.
abstract interface class SearchCacheDataSource {
  Future<void> save({
    required String query,
    required int page,
    required int numFound,
    required List<Book> books,
  });

  Future<CachedSearch?> read({required String query, required int page});
}

class SearchCacheDataSourceImpl implements SearchCacheDataSource {
  SearchCacheDataSourceImpl({required this.database});

  final Database database;

  @override
  Future<void> save({
    required String query,
    required int page,
    required int numFound,
    required List<Book> books,
  }) async {
    await database.insert(
      searchCacheTable,
      <String, Object?>{
        columnQuery: query,
        columnPage: page,
        columnNumFound: numFound,
        columnBooks: jsonEncode(books.map(_bookToJson).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<CachedSearch?> read({required String query, required int page}) async {
    final rows = await database.query(
      searchCacheTable,
      where: '$columnQuery = ? AND $columnPage = ?',
      whereArgs: [query, page],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    final decoded = jsonDecode(row[columnBooks]! as String) as List;
    final books = decoded
        .whereType<Map<String, Object?>>()
        .map(_bookFromJson)
        .toList(growable: false);

    return CachedSearch(numFound: row[columnNumFound]! as int, books: books);
  }

  static Map<String, Object?> _bookToJson(Book book) => <String, Object?>{
        'key': book.key,
        'title': book.title,
        'authors': book.authorNames,
        'cover_i': book.coverId,
        'year': book.firstPublishYear,
      };

  static Book _bookFromJson(Map<String, Object?> json) => Book(
        key: json['key']! as String,
        title: json['title']! as String,
        authorNames:
            (json['authors']! as List).whereType<String>().toList(growable: false),
        coverId: json['cover_i'] as int?,
        firstPublishYear: json['year'] as int?,
      );
}
