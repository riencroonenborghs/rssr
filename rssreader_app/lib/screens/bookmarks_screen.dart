import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';
import 'entries_list_screen.dart';

class BookmarksScreen extends StatelessWidget {
  final String cookie;

  const BookmarksScreen({super.key, required this.cookie});

  @override
  Widget build(BuildContext context) {
    final service = BookmarkService();
    return EntriesScreen(
      cookie: cookie,
      title: 'Bookmarks',
      removeOnUnbookmark: true,
      loader: (page) => service.fetchBookmarks(cookie, page: page),
    );
  }
}
