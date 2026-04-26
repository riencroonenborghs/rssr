import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entry.dart';

class FeedService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<List<Feed>> fetchFeeds(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/feeds.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
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
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
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
    final uri = Uri.parse('$_baseUrl/api/v1/feeds/$feedId/entries/$entryId.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final feed = Feed.fromJson(data['feed'] as Map<String, dynamic>);
    final map = data['entry'] as Map<String, dynamic>;
    map['feed'] = {'id': feed.id, 'title': feed.title, 'url': feed.url};
    return (feed: feed, entry: Entry.fromJson(map));
  }


}
