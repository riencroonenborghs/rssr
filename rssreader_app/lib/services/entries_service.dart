import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';
import '../models/report.dart';

class EntriesService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  // Tracks bookmark state across screens for the session lifetime.
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

  Future<({List<Entry> entries, PaginationMeta meta})> fetchUnread(
    String cookie, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/unread.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final entries = (data['entries'] as List<dynamic>)
        .map((e) => Entry.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (entries: entries, meta: meta);
  }

  Future<List<Feed>> fetchFeeds(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/feeds.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['feeds'] as List<dynamic>)
        .map((f) => Feed.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<({Feed feed, List<Entry> entries, PaginationMeta meta})> fetchFeed(
    String cookie,
    int feedId, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/feeds/$feedId.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final feed = Feed.fromJson(data['feed'] as Map<String, dynamic>);
    final entries = (data['entries'] as List<dynamic>).map((e) {
      final map = e as Map<String, dynamic>;
      map['feed'] = {'id': feed.id, 'title': feed.title, 'url': feed.url};
      return Entry.fromJson(map);
    }).toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (feed: feed, entries: entries, meta: meta);
  }

  Future<({Feed feed, Entry entry})> fetchEntry(
    String cookie,
    int feedId,
    int entryId,
  ) async {
    final uri =
        Uri.parse('$_baseUrl/api/v1/feeds/$feedId/entries/$entryId.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final feed = Feed.fromJson(data['feed'] as Map<String, dynamic>);
    final map = data['entry'] as Map<String, dynamic>;
    map['feed'] = {'id': feed.id, 'title': feed.title, 'url': feed.url};
    return (feed: feed, entry: Entry.fromJson(map));
  }

  Future<({List<Entry> entries, PaginationMeta meta})> fetchBookmarks(
    String cookie, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/bookmarks.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
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
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
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

  Future<({Tag tag, List<Entry> entries, PaginationMeta meta})> fetchTag(
    String cookie,
    int tagId, {
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/tags/$tagId.json')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = Tag.fromJson(data['tag'] as Map<String, dynamic>);
    final entries = (data['entries'] as List<dynamic>)
        .map((e) => Entry.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(data['meta'] as Map<String, dynamic>);
    return (tag: tag, entries: entries, meta: meta);
  }

  Future<List<Report>> fetchReports(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>)
        .map((r) => Report.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<DailyReport>> fetchDailyReports(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports/daily.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>)
        .map((r) => DailyReport.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<DailyReport> fetchDailyReport(String cookie, int id) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports/daily/$id.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DailyReport.fromJson(data['report'] as Map<String, dynamic>);
  }

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
