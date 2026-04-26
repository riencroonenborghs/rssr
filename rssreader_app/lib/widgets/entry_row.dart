import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/quick_link.dart';
import '../services/bookmark_service.dart';
import '../services/quick_links_service.dart';
import '../screens/entry_screen.dart';
import '../screens/feed_screen.dart';

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
    final titleColor = _viewed ? cs.onSurface.withValues(alpha: 0.4) : cs.onSurface;
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
                if (entry.publishedAt != null)
                  Text(
                    _formatDate(entry.publishedAt!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.outline,
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(width: 8),
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
