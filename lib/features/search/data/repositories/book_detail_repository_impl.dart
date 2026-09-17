import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_detail.dart';
import '../../domain/repositories/book_detail_repository.dart';
import '../datasources/book_detail_remote_data_source.dart';
import '../mappers/work_mapper.dart';

class BookDetailRepositoryImpl implements BookDetailRepository {
  BookDetailRepositoryImpl({required this.remoteDataSource});

  final BookDetailRemoteDataSource remoteDataSource;

  @override
  Future<Result<BookDetail>> getDetail(Book book) async {
    final workId = extractWorkId(book.key);
    if (workId.isEmpty) {
      return const FailureResult(
        ServerFailure('Book has no valid work id', statusCode: 404),
      );
    }
    try {
      final dto = await remoteDataSource.fetchWork(workId);
      final detail = dto.toDomain(
        authorNames: book.authorNames,
        firstPublishYear: book.firstPublishYear,
        fallbackCoverId: book.coverId,
      );
      return Success(detail);
    } on Object catch (error) {
      return FailureResult(mapErrorToFailure(error));
    }
  }
}
