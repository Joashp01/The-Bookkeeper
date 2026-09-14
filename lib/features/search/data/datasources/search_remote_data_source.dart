import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../dtos/search_response_dto.dart';

/// Interface for the search remote source. The repository depends on this
/// abstraction (not the concrete implementation), so tests can substitute a
/// fake or drive the real implementation with a mocked [http.Client].
abstract interface class SearchRemoteDataSource {
  /// Fetches one page of results for [query].
  ///
  /// Throws [ServerException] on a non-200 response and [ParsingException] when
  /// the body is not a JSON object. Transport errors from [http.Client]
  /// (e.g. `http.ClientException`) propagate to the caller.
  Future<SearchResponseDto> search({
    required String query,
    required int page,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl({required this.client});

  final http.Client client;

  static const String _host = 'openlibrary.org';
  static const String _searchPath = '/search.json';

  @override
  Future<SearchResponseDto> search({
    required String query,
    required int page,
  }) async {
    final uri = Uri.https(_host, _searchPath, <String, String>{
      'q': query,
      'page': '$page',
    });

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ParsingException('Expected a JSON object at the response root');
    }

    return SearchResponseDto.fromJson(decoded);
  }
}
