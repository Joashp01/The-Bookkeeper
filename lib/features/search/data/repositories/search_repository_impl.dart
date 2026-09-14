import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/models/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../mappers/book_mapper.dart';

/// Default [SearchRepository] backed by the remote data source.
///
/// Data-layer exceptions are translated into typed failures by the shared
/// [mapErrorToFailure]; there is no empty catch. The [NetworkFailure] it can
/// produce is the seam the offline feature (F4) hooks into to serve cache.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required this.remoteDataSource});

  final SearchRemoteDataSource remoteDataSource;

  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) async {
    try {
      final dto = await remoteDataSource.search(query: query, page: page);
      final books =
          dto.docs.map((doc) => doc.toDomain()).toList(growable: false);
      return Success(
        SearchResult(books: books, numFound: dto.numFound, page: page),
      );
    } on Object catch (error) {
      return FailureResult(mapErrorToFailure(error));
    }
  }
}
