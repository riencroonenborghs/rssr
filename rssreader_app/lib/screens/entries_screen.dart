import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/feed.dart';
import '../models/pagination_meta.dart';
import '../models/report.dart';
import '../services/bookmark_service.dart';
import '../services/feed_service.dart';
import '../services/report_service.dart';
import '../services/tag_service.dart';
import '../models/quick_link.dart';
import '../services/quick_links_service.dart';
import '../main.dart';
import 'entry_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

// Reusable paginated entries list used by FeedScreen and TagScreen.
class EntriesScreen extends StatefulWidget {
  final String cookie;
  final String title;
  final String? subtitle;
  final Future<({List<Entry> entries, PaginationMeta meta})> Function(int page) loader;
  final bool removeOnUnbookmark;

  const EntriesScreen({
    super.key,
    required this.cookie,
    required this.title,
    this.subtitle,
    required this.loader,
    this.removeOnUnbookmark = false,
  });

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  List<Entry> _entries = [];
  PaginationMeta? _meta;
  bool _loading = true;
  String? _error;
  int _page = 1;
  bool _loadingMore = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _meta != null &&
        _page < _meta!.totalPages) {
      _loadMore();
    }
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _entries = [];
        _error = null;
        _loading = true;
      });
    }
    try {
      final result = await widget.loader(1);
      if (!mounted) return;
      setState(() {
        _entries = result.entries;
        _meta = result.meta;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onUnbookmarked(int entryId) {
    setState(() => _entries.removeWhere((e) => e.id == entryId));
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await widget.loader(_page + 1);
      if (!mounted) return;
      setState(() {
        _page++;
        _entries = [..._entries, ...result.entries];
        _meta = result.meta;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (_meta != null)
              Text(
                '${_meta!.totalCount} entries',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    if (_error != null) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 52, color: cs.outline),
              const SizedBox(height: 16),
              Text(
                'Could not load entries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: cs.outline),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _load(refresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_entries.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'No entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nothing here yet.',
              style: TextStyle(fontSize: 14, color: cs.outline),
            ),
          ],
        ),
      );
    }

    final isTable = RssrApp.of(context).viewMode == ViewMode.table;

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: isTable
            ? EdgeInsets.zero
            : EdgeInsets.zero,
        itemCount: _entries.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _entries.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (isTable) {
            return EntryRow(
              entry: _entries[index],
              cookie: widget.cookie,
              onUnbookmarked: widget.removeOnUnbookmark ? _onUnbookmarked : null,
            );
          }
          return EntryCard(
            entry: _entries[index],
            cookie: widget.cookie,
            onUnbookmarked: widget.removeOnUnbookmark ? _onUnbookmarked : null,
          );
        },
      ),
    );
  }
}

// Feed entries screen
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

// Bookmarks screen
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

// Tag entries screen
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

// Shared entry card used by all screens
class EntryCard extends StatefulWidget {
  final Entry entry;
  final String cookie;
  final void Function(int entryId)? onUnbookmarked;

  const EntryCard({
    super.key,
    required this.entry,
    required this.cookie,
    this.onUnbookmarked,
  });

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  final _quickLinksService = QuickLinksService();

  late bool _viewed = widget.entry.viewed;
  late bool _bookmarked =
      BookmarkService.bookmarkOverride(widget.entry.id) ?? widget.entry.bookmarked;
  bool _bookmarkLoading = false;
  final _service = BookmarkService();

  @override
  void didUpdateWidget(EntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _bookmarked =
          BookmarkService.bookmarkOverride(widget.entry.id) ?? widget.entry.bookmarked;
    }
  }

  Future<void> _openEntry(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryScreen(
          cookie: widget.cookie,
          feedId: widget.entry.feed.id,
          entryId: widget.entry.id,
          previewTitle: widget.entry.title,
          previewImage: widget.entry.image,
        ),
      ),
    );
    if (mounted && !_viewed) setState(() => _viewed = true);
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      if (_bookmarked) {
        await _service.deleteBookmark(widget.cookie, widget.entry.id);
        if (mounted) {
          setState(() => _bookmarked = false);
          widget.onUnbookmarked?.call(widget.entry.id);
        }
      } else {
        await _service.createBookmark(widget.cookie, widget.entry.id);
        if (mounted) setState(() => _bookmarked = true);
      }
    } catch (_) {
      // silently ignore — button returns to previous state
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final entry = widget.entry;
    final hasImage = entry.image != null && entry.image!.isNotEmpty;

    final viewed = _viewed;
    final cardColor = viewed
        ? (isDark ? const Color(0xFF141A14) : const Color(0xFFEFF5EF))
        : (isDark ? Colors.black : Colors.white);
    final titleColor = viewed
        ? cs.onSurface.withValues(alpha: 0.45)
        : cs.onSurface;
    final feedColor = viewed
        ? cs.outline
        : cs.primary;

    return Column(
      children: [
        Material(
        color: cardColor,
        borderRadius: BorderRadius.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openEntry(context),
          splashColor: cs.primary.withValues(alpha: 0.06),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 12, bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                  width: 88,
                  height: 88,
                  child: ColorFiltered(
                    colorFilter: viewed
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      0.5, 0,
                          ])
                        : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                    child: Image.network(
                      entry.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                    ),
                  ),
                    ),
                  ),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Feed + date + bookmark row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FeedScreen(
                                  cookie: widget.cookie,
                                  feedId: entry.feed.id,
                                  feedTitle: entry.feed.title,
                                ),
                              ),
                            ),
                            onLongPress: () async {
                              await _quickLinksService.add(QuickLink(
                                id: entry.feed.id,
                                title: entry.feed.title,
                                type: QuickLinkType.feed,
                              ));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${entry.feed.title} added to quick links'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: viewed
                                      ? cs.outline.withValues(alpha: 0.15)
                                      : cs.primary.withValues(alpha: 0.12),
                                  child: Text(
                                    entry.feed.title.isNotEmpty
                                        ? entry.feed.title[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: feedColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.feed.title,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: feedColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (viewed)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Read',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.outline,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          if (entry.publishedAt != null)
                            Text(
                              _formatDate(entry.publishedAt!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.outline,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _toggleBookmark,
                            child: _bookmarkLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: cs.primary,
                                    ),
                                  )
                                : Icon(
                                    _bookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_outline_rounded,
                                    size: 18,
                                    color: _bookmarked ? cs.primary : cs.outline,
                                  ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Title
                      Text(
                        entry.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: viewed ? FontWeight.w400 : FontWeight.w600,
                          color: titleColor,
                          height: 1.3,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (!viewed &&
                          entry.description != null &&
                          entry.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          entry.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                            height: 1.4,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Tags
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.tags.map((tag) {
                            return GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TagScreen(
                                    cookie: widget.cookie,
                                    tagId: tag.id,
                                    tagName: tag.name,
                                  ),
                                ),
                              ),
                              onLongPress: () async {
                                await _quickLinksService.add(QuickLink(
                                  id: tag.id,
                                  title: tag.name,
                                  type: QuickLinkType.tag,
                                ));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${tag.name} added to quick links'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: viewed
                                      ? (isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC))
                                      : (isDark ? cs.primary.withValues(alpha: 0.15) : cs.secondaryContainer),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: viewed
                                        ? cs.outline
                                        : (isDark ? cs.primary : cs.onSecondaryContainer),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        Divider(height: 1, thickness: 1, color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 6) return '${dt.month}/${dt.day}';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

// Table view row
class EntryRow extends StatefulWidget {
  final Entry entry;
  final String cookie;
  final void Function(int entryId)? onUnbookmarked;

  const EntryRow({
    super.key,
    required this.entry,
    required this.cookie,
    this.onUnbookmarked,
  });

  @override
  State<EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> {
  final _quickLinksService = QuickLinksService();
  final _service = BookmarkService();

  late bool _viewed = widget.entry.viewed;
  late bool _bookmarked =
      BookmarkService.bookmarkOverride(widget.entry.id) ?? widget.entry.bookmarked;
  bool _bookmarkLoading = false;

  Future<void> _openEntry(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryScreen(
          cookie: widget.cookie,
          feedId: widget.entry.feed.id,
          entryId: widget.entry.id,
          previewTitle: widget.entry.title,
          previewImage: widget.entry.image,
        ),
      ),
    );
    if (mounted && !_viewed) setState(() => _viewed = true);
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      if (_bookmarked) {
        await _service.deleteBookmark(widget.cookie, widget.entry.id);
        if (mounted) {
          setState(() => _bookmarked = false);
          widget.onUnbookmarked?.call(widget.entry.id);
        }
      } else {
        await _service.createBookmark(widget.cookie, widget.entry.id);
        if (mounted) setState(() => _bookmarked = true);
      }
    } catch (_) {
      // silently ignore
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final entry = widget.entry;

    final rowColor = _viewed
        ? (isDark ? const Color(0xFF141A14) : const Color(0xFFEFF5EF))
        : (isDark ? Colors.black : Colors.white);
    final titleColor = _viewed
        ? cs.onSurface.withValues(alpha: 0.4)
        : cs.onSurface;
    final feedColor = _viewed ? cs.outline : cs.primary;

    return Column(
      children: [
        InkWell(
          onTap: () => _openEntry(context),
          child: Container(
            color: rowColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or feed avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: entry.image != null && entry.image!.isNotEmpty
                      ? ColorFiltered(
                          colorFilter: _viewed
                              ? const ColorFilter.matrix([
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      0.6, 0,
                                ])
                              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                          child: Image.network(
                            entry.image!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _feedAvatar(cs, theme, isDark),
                          ),
                        )
                      : _feedAvatar(cs, theme, isDark),
                ),
                const SizedBox(width: 10),

                // Title + feed
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: titleColor,
                          fontWeight: _viewed ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FeedScreen(
                              cookie: widget.cookie,
                              feedId: entry.feed.id,
                              feedTitle: entry.feed.title,
                            ),
                          ),
                        ),
                        onLongPress: () async {
                          await _quickLinksService.add(QuickLink(
                            id: entry.feed.id,
                            title: entry.feed.title,
                            type: QuickLinkType.feed,
                          ));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${entry.feed.title} added to quick links'),
                              duration: const Duration(seconds: 2),
                            ));
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 7,
                              backgroundColor: _viewed
                                  ? cs.outline.withValues(alpha: 0.15)
                                  : cs.primary.withValues(alpha: 0.12),
                              child: Text(
                                entry.feed.title.isNotEmpty
                                    ? entry.feed.title[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: feedColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                entry.feed.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: feedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Date
                if (entry.publishedAt != null)
                  Text(
                    _formatDate(entry.publishedAt!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.outline,
                      fontSize: 11,
                    ),
                  ),

                const SizedBox(width: 8),

                // Bookmark
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: _bookmarkLoading
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          _bookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: 16,
                          color: _bookmarked ? cs.primary : cs.outline,
                        ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 0,
          color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC),
        ),
      ],
    );
  }

  Widget _feedAvatar(ColorScheme cs, ThemeData theme, bool isDark) {
    final initials = widget.entry.feed.title.length >= 2
        ? widget.entry.feed.title.substring(0, 2).toUpperCase()
        : widget.entry.feed.title.toUpperCase();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _viewed
            ? (isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC))
            : cs.primary.withValues(alpha: 0.12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: theme.textTheme.labelMedium?.copyWith(
          color: _viewed ? cs.outline : cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 6) return '${dt.month}/${dt.day}';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}

class _AccordionHeader extends StatelessWidget {
  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme cs;

  const _AccordionHeader({
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.outline,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.expand_more, size: 16, color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NavItem({
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      leading: icon != null
          ? Icon(icon, size: 20, color: selected ? cs.primary : cs.outline)
          : CircleAvatar(
              radius: 12,
              backgroundColor: selected
                  ? cs.primary
                  : cs.primary.withValues(alpha: 0.12),
              child: Text(
                label[0].toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? cs.onPrimary : cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: selected ? cs.primary : cs.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      minLeadingWidth: 20,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

// Drawer shared across screens
class AppDrawer extends StatefulWidget {
  final VoidCallback onSignOut;
  final String cookie;
  final String activeRoute;

  const AppDrawer({
    super.key,
    required this.onSignOut,
    required this.cookie,
    this.activeRoute = 'unread',
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _feedService = FeedService();
  final _reportService = ReportService();
  final _quickLinksService = QuickLinksService();
  List<Feed> _feeds = [];
  bool _feedsExpanded = false;
  List<Report> _reports = [];
  bool _reportsExpanded = false;
  List<QuickLink> _quickLinks = [];
  bool _quickLinksExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
    _loadReports();
    _loadQuickLinks();
  }

  Future<void> _loadFeeds() async {
    try {
      final feeds = await _feedService.fetchFeeds(widget.cookie);
      if (mounted) setState(() => _feeds = feeds);
    } catch (_) {}
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.fetchReports(widget.cookie);
      if (mounted) setState(() => _reports = reports);
    } catch (_) {}
  }

  Future<void> _loadQuickLinks() async {
    final links = await _quickLinksService.load();
    if (mounted) setState(() => _quickLinks = links);
  }

  Future<void> _removeQuickLink(int id, QuickLinkType type) async {
    await _quickLinksService.remove(id, type);
    if (mounted) setState(() => _quickLinks.removeWhere((l) => l.id == id && l.type == type));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1C18) : const Color(0xFFFBF9F5),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.rss_feed_rounded, size: 22, color: cs.primary),
                const SizedBox(width: 10),
                Text(
                  'RSS Reader',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              children: [
                _NavItem(
                  icon: Icons.inbox_outlined,
                  label: 'Unread',
                  selected: widget.activeRoute == 'unread',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _NavItem(
                  icon: Icons.bookmark_outline_rounded,
                  label: 'Bookmarks',
                  selected: widget.activeRoute == 'bookmarks',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (widget.activeRoute != 'bookmarks') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookmarksScreen(cookie: widget.cookie),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                _AccordionHeader(
                  label: 'QUICK LINKS',
                  expanded: _quickLinksExpanded,
                  onTap: () => setState(() => _quickLinksExpanded = !_quickLinksExpanded),
                  theme: theme,
                  cs: cs,
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _quickLinksExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _quickLinks.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
                          child: Text(
                            'Press and hold feeds and tags for quick access',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.outline,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        )
                      : Column(
                          children: _quickLinks.map((link) {
                            final icon = link.type == QuickLinkType.feed
                                ? null
                                : Icons.label_outline_rounded;
                            return _NavItem(
                              icon: icon,
                              label: link.title,
                              selected: false,
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => link.type == QuickLinkType.feed
                                        ? FeedScreen(
                                            cookie: widget.cookie,
                                            feedId: link.id,
                                            feedTitle: link.title,
                                          )
                                        : TagScreen(
                                            cookie: widget.cookie,
                                            tagId: link.id,
                                            tagName: link.title,
                                          ),
                                  ),
                                );
                              },
                              onLongPress: () async {
                                await _removeQuickLink(link.id, link.type);
                              },
                            );
                          }).toList(),
                        ),
                  secondChild: const SizedBox.shrink(),
                ),
                if (_feeds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _AccordionHeader(
                    label: 'FEEDS',
                    expanded: _feedsExpanded,
                    onTap: () => setState(() => _feedsExpanded = !_feedsExpanded),
                    theme: theme,
                    cs: cs,
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _feedsExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: _feeds.map((feed) => _NavItem(
                            label: feed.title,
                            selected: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FeedScreen(
                                    cookie: widget.cookie,
                                    feedId: feed.id,
                                    feedTitle: feed.title,
                                  ),
                                ),
                              );
                            },
                          )).toList(),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
                if (_reports.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _AccordionHeader(
                    label: 'REPORTS',
                    expanded: _reportsExpanded,
                    onTap: () => setState(() => _reportsExpanded = !_reportsExpanded),
                    theme: theme,
                    cs: cs,
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _reportsExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: _reports.map((report) => _NavItem(
                            icon: Icons.summarize_outlined,
                            label: report.keywords.join(', '),
                            selected: false,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReportDailyListScreen(
                                    cookie: widget.cookie,
                                    report: report,
                                  ),
                                ),
                              );
                            },
                          )).toList(),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC),
            indent: 20,
            endIndent: 20,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: widget.activeRoute == 'settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    if (widget.activeRoute != 'settings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SettingsScreen(cookie: widget.cookie)),
                      );
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.logout,
                  label: 'Sign out',
                  selected: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSignOut();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ReportDailyListScreen extends StatefulWidget {
  final String cookie;
  final Report report;

  const ReportDailyListScreen({
    super.key,
    required this.cookie,
    required this.report,
  });

  @override
  State<ReportDailyListScreen> createState() => _ReportDailyListScreenState();
}

class _ReportDailyListScreenState extends State<ReportDailyListScreen> {
  final _service = ReportService();
  List<DailyReport> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reports = await _service.fetchDailyReports(widget.cookie);
      if (!mounted) return;
      setState(() { _reports = reports; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.report.keywords.join(', ')),
            Text('Reports', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: cs.error)))
              : _reports.isEmpty
                  ? Center(
                      child: Text('No reports yet', style: TextStyle(color: cs.outline)),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _reports.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC),
                      ),
                      itemBuilder: (context, index) {
                        final r = _reports[index];
                        final preview = r.summary != null && r.summary!.isNotEmpty
                            ? r.summary!.substring(0, r.summary!.length.clamp(0, 100))
                            : null;
                        return ListTile(
                          leading: Icon(Icons.summarize_outlined, size: 20, color: cs.outline),
                          title: Text(_formatDate(r.createdAt)),
                          subtitle: preview != null
                              ? Text(
                                  preview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                                )
                              : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReportScreen(
                                cookie: widget.cookie,
                                reportId: r.id,
                                previewDate: r.createdAt,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
