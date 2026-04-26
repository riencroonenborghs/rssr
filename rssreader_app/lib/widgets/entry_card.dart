import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/quick_link.dart';
import '../services/bookmark_service.dart';
import '../services/quick_links_service.dart';
import '../screens/entry_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/tag_screen.dart';

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
    final titleColor = viewed ? cs.onSurface.withValues(alpha: 0.45) : cs.onSurface;
    final feedColor = viewed ? cs.outline : cs.primary;

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
