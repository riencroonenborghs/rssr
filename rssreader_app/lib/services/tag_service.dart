import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../models/pagination_meta.dart';
import '../models/tag.dart';

class TagService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<({Tag tag, List<Entry> entries, PaginationMeta meta})> fetchTag(
    String cookie,
    int tagId, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/tags/$tagId.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = Tag.fromJson(data['tag'] as Map<String, dynamic>);
    final entries = (data['entries'] as List<dynamic>)
        .map((e) => Entry.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (tag: tag, entries: entries, meta: meta);
  }
}
