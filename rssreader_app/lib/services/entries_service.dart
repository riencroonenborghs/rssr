import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';

class EntriesService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<({List<Entry> entries, PaginationMeta meta})> fetchUnread(
    String cookie, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/unread.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final entries = (data['entries'] as List<dynamic>)
        .map((e) => Entry.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (entries: entries, meta: meta);
  }
}
