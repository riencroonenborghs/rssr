import 'package:flutter/material.dart';
import '../models/feed.dart';
import '../models/quick_link.dart';
import '../models/report.dart';
import '../services/feed_service.dart';
import '../services/quick_links_service.dart';
import '../services/report_service.dart';
import 'bookmarks_screen.dart';
import 'feed_screen.dart';
import 'report_daily_list_screen.dart';
import 'settings_screen.dart';
import 'tag_screen.dart';

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
                            icon: Icons.article_outlined,
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
              backgroundColor: selected ? cs.primary : cs.primary.withValues(alpha: 0.12),
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
