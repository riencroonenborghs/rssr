import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filter.dart';
import '../models/pagination_meta.dart';

class FilterService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<({List<Filter> filters, PaginationMeta meta})> fetchFilters(
    String cookie, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/filters.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final filters = (data['filters'] as List<dynamic>)
        .map((f) => Filter.fromJson(f as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (filters: filters, meta: meta);
  }

  Future<int> createFilter(String cookie, String comparison, String value) async {
    final uri = Uri.parse('$_baseUrl/api/v1/filters.json');
    final response = await http.post(
      uri,
      headers: _headers(cookie),
      body: jsonEncode({'filter': {'comparison': comparison, 'value': value}}),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['errors'] as String? ?? 'HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['filter_id'] as int;
  }

  Future<void> deleteFilter(String cookie, int filterId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/filters/$filterId.json');
    final response = await http.delete(uri, headers: _headers(cookie));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}
