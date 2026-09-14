import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../dtos/work_dto.dart';

/// Interface for the works (detail) remote source. The repository depends on
/// this abstraction so tests can drive the real implementation with a mocked
/// [http.Client].
abstract interface class BookDetailRemoteDataSource {
  /// Fetches the work document for [workId] (the trailing segment of a key).
  ///
  /// Throws [ServerException] on a non-200 response and [ParsingException] when
  /// the body is not a JSON object.
  Future<WorkDto> fetchWork(String workId);
}

class BookDetailRemoteDataSourceImpl implements BookDetailRemoteDataSource {
  BookDetailRemoteDataSourceImpl({required this.client});

  final http.Client client;

  static const String _host = 'openlibrary.org';

  @override
  Future<WorkDto> fetchWork(String workId) async {
    final uri = Uri.https(_host, '/works/$workId.json');

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ParsingException('Expected a JSON object at the response root');
    }

    return WorkDto.fromJson(decoded);
  }
}
