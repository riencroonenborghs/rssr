import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/entry.dart';
import '../services/entries_service.dart';
import '../services/quick_links_service.dart';
import 'entries_screen.dart';

class EntryScreen extends StatefulWidget {
  final String cookie;
  final int feedId;
  final int entryId;
  final String? previewTitle;
  final String? previewImage;

  const EntryScreen({
    super.key,
    required this.cookie,
    required this.feedId,
    required this.entryId,
    this.previewTitle,
    this.previewImage,
  });

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _service = EntriesService();
  final _quickLinksService = QuickLinksService();
  Feed? _feed;
  Entry? _entry;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _service.fetchEntry(widget.cookie, widget.feedId, widget.entryId);
      if (!mounted) return;
      setState(() {
        _feed = r.feed;
        _entry = r.entry;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141A14) : Colors.white,
      body: _loading
          ? _buildLoading(cs)
          : _error != null
              ? _buildError(cs)
              : _buildContent(theme, cs, isDark),
    );
  }

  Widget _buildLoading(ColorScheme cs) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: widget.previewImage != null ? 280 : 0,
          flexibleSpace: widget.previewImage != null
              ? FlexibleSpaceBar(
                  background: Image.network(
                    widget.previewImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                )
              : null,
        ),
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: cs.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildError(ColorScheme cs) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 52, color: cs.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load entry',
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
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _load();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme cs, bool isDark) {
    final entry = _entry!;
    final feed = _feed!;
    final hasImage = entry.image != null && entry.image!.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // Collapsing app bar with hero image
        SliverAppBar(
          pinned: true,
          expandedHeight: hasImage ? 280 : 0,
          flexibleSpace: hasImage
              ? FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        entry.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox.shrink(),
                      ),
                      // Gradient so back button stays readable
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x88000000),
                              Colors.transparent,
                              Color(0x66000000),
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          actions: [
            if (entry.link.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.open_in_browser_rounded),
                tooltip: 'Open in browser',
                onPressed: () => _openLink(entry.link),
              ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feed source row
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FeedScreen(
                        cookie: widget.cookie,
                        feedId: feed.id,
                        feedTitle: feed.title,
                      ),
                    ),
                  ),
                  onLongPress: () async {
                    await _quickLinksService.add(QuickLink(
                      id: feed.id,
                      title: feed.title,
                      type: QuickLinkType.feed,
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${feed.title} added to quick links'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: cs.primary.withValues(alpha: 0.12),
                        child: Text(
                          feed.title.isNotEmpty
                              ? feed.title[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        feed.title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  entry.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Meta row: date + bookmark
                Row(
                  children: [
                    if (entry.publishedAt != null) ...[
                      Icon(Icons.schedule_rounded,
                          size: 13, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(entry.publishedAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.outline,
                        ),
                      ),
                    ],
                    if (entry.bookmarked) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.bookmark_rounded,
                          size: 14, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Bookmarked',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
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
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? cs.primary.withValues(alpha: 0.15)
                                : cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.name,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? cs.primary
                                  : cs.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF1E2E1F)
                        : const Color(0xFFDCEBDC),
                  ),
                  const SizedBox(height: 24),
                  _DescriptionBody(
                    html: entry.description!,
                    theme: theme,
                    cs: cs,
                    isDark: isDark,
                  ),
                ],

                // Open link button
                if (entry.link.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openLink(entry.link),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text('Read full article'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark
                              ? cs.primary.withValues(alpha: 0.5)
                              : cs.primary.withValues(alpha: 0.4),
                        ),
                        foregroundColor: cs.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// Renders the description. RSS descriptions are often HTML snippets.
// Without a WebView or html_unescape package we render the raw text but
// strip the most common tags so it reads cleanly.
class _DescriptionBody extends StatelessWidget {
  final String html;
  final ThemeData theme;
  final ColorScheme cs;
  final bool isDark;

  const _DescriptionBody({
    required this.html,
    required this.theme,
    required this.cs,
    required this.isDark,
  });

  static String _stripTags(String input) {
    // Remove <style> and <script> blocks entirely
    var out = input.replaceAll(
        RegExp(r'<(style|script)[^>]*>.*?</(style|script)>',
            caseSensitive: false, dotAll: true),
        '');
    // Replace block-level tags with newlines
    out = out.replaceAll(
        RegExp(r'<(br|/p|/div|/li|/h\d)[^>]*>', caseSensitive: false), '\n');
    // Strip remaining tags
    out = out.replaceAll(RegExp(r'<[^>]+>'), '');
    // Decode common HTML entities
    out = out
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '…');
    // Collapse excessive blank lines
    out = out.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final text = _stripTags(html);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.85),
        height: 1.7,
        letterSpacing: 0.1,
      ),
    );
  }
}
