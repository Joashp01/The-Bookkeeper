import '../../../../core/error/result.dart';
import '../models/search_result.dart';

abstract interface class SearchRepository {
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  });
}
