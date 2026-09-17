import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../dtos/work_dto.dart';

abstract interface class BookDetailRemoteDataSource {
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
      throw const ParsingException(
        'Expected a JSON object at the response root',
      );
    }

    return WorkDto.fromJson(decoded);
  }
}
