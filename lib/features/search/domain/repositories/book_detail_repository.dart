import '../../../../core/error/result.dart';
import '../models/book.dart';
import '../models/book_detail.dart';

/// Domain contract for loading a book's full detail.
///
/// Takes the originating search [Book] so author names, year and cover (which
/// the works endpoint may omit) can be threaded through onto the [BookDetail].
abstract interface class BookDetailRepository {
  Future<Result<BookDetail>> getDetail(Book book);
}
