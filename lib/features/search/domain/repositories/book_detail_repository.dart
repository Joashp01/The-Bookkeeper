import '../../../../core/error/result.dart';
import '../models/book.dart';
import '../models/book_detail.dart';

abstract interface class BookDetailRepository {
  Future<Result<BookDetail>> getDetail(Book book);
}
