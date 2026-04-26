import 'package:flutter/material.dart';
import '../services/feed_service.dart';
import 'entries_list_screen.dart';

class FeedScreen extends StatelessWidget {
  final String cookie;
  final int feedId;
  final String feedTitle;

  const FeedScreen({
    super.key,
    required this.cookie,
    required this.feedId,
    required this.feedTitle,
  });

  @override
  Widget build(BuildContext context) {
    final service = FeedService();
    return EntriesScreen(
      cookie: cookie,
      title: feedTitle,
      loader: (page) async {
        final r = await service.fetchFeed(cookie, feedId, page: page);
        return (entries: r.entries, meta: r.meta);
      },
    );
  }
}
