import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum QuickLinkType { feed, tag }

class QuickLink {
  final int id;
  final String title;
  final QuickLinkType type;

  const QuickLink({required this.id, required this.title, required this.type});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
      };

  factory QuickLink.fromJson(Map<String, dynamic> json) => QuickLink(
        id: json['id'] as int,
        title: json['title'] as String,
        type: QuickLinkType.values.byName(json['type'] as String),
      );
}

class QuickLinksService {
  static const _key = 'quick_links';

  Future<List<QuickLink>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => QuickLink.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add(QuickLink link) async {
    final links = await load();
    if (links.any((l) => l.id == link.id && l.type == link.type)) return;
    links.add(link);
    await _save(links);
  }

  Future<void> remove(int id, QuickLinkType type) async {
    final links = await load();
    links.removeWhere((l) => l.id == id && l.type == type);
    await _save(links);
  }

  Future<void> _save(List<QuickLink> links) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(links.map((l) => l.toJson()).toList()));
  }
}
