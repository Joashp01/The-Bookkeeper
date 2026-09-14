import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/models/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../mappers/book_mapper.dart';

/// Default [SearchRepository] backed by the remote data source.
///
/// This is the single place data-layer exceptions are caught and translated
/// into typed [Failure]s. Each branch is handled explicitly — there is no empty
/// catch. The [NetworkFailure] branch is the seam the offline feature (F4) will
/// hook into to serve cached results.
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
      final books = dto.docs.map((doc) => doc.toDomain()).toList(growable: false);
      return Success(
        SearchResult(books: books, numFound: dto.numFound, page: page),
      );
    } on ServerException catch (e) {
      return FailureResult(
        ServerFailure(e.message, statusCode: e.statusCode),
      );
    } on ParsingException catch (e) {
      return FailureResult(ParsingFailure(e.message));
    } on FormatException catch (e) {
      return FailureResult(ParsingFailure('Malformed response: ${e.message}'));
    } on http.ClientException catch (e) {
      return FailureResult(NetworkFailure(e.message));
    }
  }
}
