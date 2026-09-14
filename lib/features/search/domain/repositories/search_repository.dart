import '../../../../core/error/result.dart';
import '../models/search_result.dart';

/// Domain-facing contract for searching books.
///
/// Returns a [Result] rather than throwing, so the presentation layer handles
/// success and every [Failure] explicitly. The concrete implementation lives in
/// the data layer and is injected via DI.
abstract interface class SearchRepository {
  Future<Result<SearchResult>> search({
    required String query,
    required int page,
  });
}
