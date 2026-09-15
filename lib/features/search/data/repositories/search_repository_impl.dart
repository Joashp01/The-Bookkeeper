import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/connectivity_checker.dart';
import '../../domain/models/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_cache_data_source.dart';
import '../datasources/search_remote_data_source.dart';
import '../mappers/book_mapper.dart';

/// Default [SearchRepository] backed by the remote data source, with an offline
/// fallback (F4).
///
/// On a successful fetch the page is cached. When a request fails and the device
/// is offline, the cached page (if any) is served with `isOffline: true` so the
/// UI can show an offline indicator. Data-layer exceptions are translated by the
/// shared [mapErrorToFailure]; there is no empty catch.
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.cache,
    required this.connectivity,
  });

  final SearchRemoteDataSource remoteDataSource;
  final SearchCacheDataSource cache;
  final ConnectivityChecker connectivity;

  @override
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  }) async {
    try {
      final dto = await remoteDataSource.search(query: query, page: page);
      final books =
          dto.docs.map((doc) => doc.toDomain()).toList(growable: false);
      await cache.save(
        query: query,
        page: page,
        numFound: dto.numFound,
        books: books,
      );
      return Success(
        SearchResult(books: books, numFound: dto.numFound, page: page),
      );
    } on Object catch (error) {
      final failure = mapErrorToFailure(error);
      return _fallbackToCache(query: query, page: page, failure: failure);
    }
  }

  /// Serves cached results when the failure was caused by being offline;
  /// otherwise returns the original failure.
  Future<Result<SearchResult>> _fallbackToCache({
    required String query,
    required int page,
    required Failure failure,
  }) async {
    if (failure is! NetworkFailure || await connectivity.hasConnection()) {
      return FailureResult(failure);
    }

    final cached = await cache.read(query: query, page: page);
    if (cached == null) {
      return FailureResult(failure);
    }

    return Success(
      SearchResult(
        books: cached.books,
        numFound: cached.numFound,
        page: page,
        isOffline: true,
      ),
    );
  }
}
