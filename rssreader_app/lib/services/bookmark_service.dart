import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../models/pagination_meta.dart';

class BookmarkService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  static final Set<int> _bookmarkedIds = {};
  static final Set<int> _unbookmarkedIds = {};

  static bool? bookmarkOverride(int entryId) {
    if (_bookmarkedIds.contains(entryId)) return true;
    if (_unbookmarkedIds.contains(entryId)) return false;
    return null;
  }

  static void recordBookmarked(int entryId) {
    _bookmarkedIds.add(entryId);
    _unbookmarkedIds.remove(entryId);
  }

  static void recordUnbookmarked(int entryId) {
    _unbookmarkedIds.add(entryId);
    _bookmarkedIds.remove(entryId);
  }

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<({List<Entry> entries, PaginationMeta meta})> fetchBookmarks(
    String cookie, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/bookmarks.json')
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

  Future<int> createBookmark(String cookie, int entryId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/bookmarks.json');
    final response = await http.post(
      uri,
      headers: _headers(cookie),
      body: jsonEncode({'entry_id': entryId}),
    );
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    recordBookmarked(entryId);
    return data['bookmark_id'] as int;
  }

  Future<void> deleteBookmark(String cookie, int entryId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/bookmarks/$entryId.json');
    final response = await http.delete(uri, headers: _headers(cookie));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('HTTP ${response.statusCode}');
    }
    recordUnbookmarked(entryId);
  }
}
