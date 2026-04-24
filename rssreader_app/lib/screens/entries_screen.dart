import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/entries_service.dart';
import '../services/quick_links_service.dart';
import 'entry_screen.dart';
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

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        itemCount: _entries.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _entries.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
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
    final service = EntriesService();
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
    final service = EntriesService();
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
    final service = EntriesService();
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
      EntriesService.bookmarkOverride(widget.entry.id) ?? widget.entry.bookmarked;
  bool _bookmarkLoading = false;
  final _service = EntriesService();

  @override
  void didUpdateWidget(EntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _bookmarked =
          EntriesService.bookmarkOverride(widget.entry.id) ?? widget.entry.bookmarked;
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
        ? (isDark ? const Color(0xFF0F1219) : const Color(0xFFF7F8FA))
        : (isDark ? const Color(0xFF161B27) : Colors.white);
    final titleColor = viewed
        ? cs.onSurface.withValues(alpha: 0.45)
        : cs.onSurface;
    final feedColor = viewed
        ? cs.outline
        : cs.primary;
    final dotColor = viewed ? cs.outline : cs.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openEntry(context),
          splashColor: cs.primary.withValues(alpha: 0.06),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ColorFiltered(
                    colorFilter: viewed
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      0.5, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst),
                    child: Image.network(
                      entry.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(12, hasImage ? 10 : 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feed + date + viewed badge row
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
                              Container(
                                width: 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.only(right: 7, top: 1),
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF252830)
                                  : const Color(0xFFEBEDF2),
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

                    const SizedBox(height: 5),

                    // Title
                    Text(
                      entry.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: viewed ? FontWeight.w400 : FontWeight.w600,
                        color: titleColor,
                        height: 1.3,
                        letterSpacing: -0.1,
                      ),
                      maxLines: hasImage ? 2 : 3,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: viewed
                                    ? (isDark
                                        ? const Color(0xFF1C2030)
                                        : const Color(0xFFEBEDF2))
                                    : (isDark
                                        ? cs.primary.withValues(alpha: 0.15)
                                        : cs.secondaryContainer),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: viewed
                                      ? cs.outline
                                      : (isDark
                                          ? cs.primary
                                          : cs.onSecondaryContainer),
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
            ],
          ),
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
                label.length >= 2 ? label.substring(0, 2).toUpperCase() : label.toUpperCase(),
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
  final _service = EntriesService();
  final _quickLinksService = QuickLinksService();
  List<Feed> _feeds = [];
  bool _feedsExpanded = true;
  List<QuickLink> _quickLinks = [];

  @override
  void initState() {
    super.initState();
    _loadFeeds();
    _loadQuickLinks();
  }

  Future<void> _loadFeeds() async {
    try {
      final feeds = await _service.fetchFeeds(widget.cookie);
      if (mounted) setState(() => _feeds = feeds);
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
              color: isDark ? const Color(0xFF161A24) : cs.primary,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF252830)
                      : cs.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rss_feed_rounded,
                  size: 22,
                  color: isDark ? cs.primary : cs.onPrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  'RSS Reader',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? cs.onSurface : cs.onPrimary,
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
                if (_quickLinks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: Text(
                      'QUICK LINKS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.outline,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ..._quickLinks.map((link) {
                    final icon = link.type == QuickLinkType.feed
                        ? Icons.rss_feed_rounded
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
                  }),
                ],
                if (_feeds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _feedsExpanded = !_feedsExpanded),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                      child: Row(
                        children: [
                          Text(
                            'FEEDS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.outline,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _feedsExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.expand_more, size: 16, color: cs.outline),
                          ),
                        ],
                      ),
                    ),
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
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF252830) : const Color(0xFFE4EAF4),
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
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

