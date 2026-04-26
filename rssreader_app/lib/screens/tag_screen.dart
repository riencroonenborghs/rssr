import 'package:flutter/material.dart';
import '../services/tag_service.dart';
import 'entries_list_screen.dart';

class TagScreen extends StatelessWidget {
  final String cookie;
  final int tagId;
  final String tagName;

  const TagScreen({
    super.key,
    required this.cookie,
    required this.tagId,
    required this.tagName,
  });

  @override
  Widget build(BuildContext context) {
    final service = TagService();
    return EntriesScreen(
      cookie: cookie,
      title: tagName,
      loader: (page) async {
        final r = await service.fetchTag(cookie, tagId, page: page);
        return (entries: r.entries, meta: r.meta);
      },
    );
  }
}
