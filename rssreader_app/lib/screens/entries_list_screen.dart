import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/pagination_meta.dart';
import '../main.dart';
import '../widgets/entry_card.dart';
import '../widgets/entry_row.dart';

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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            Text('Nothing here yet.', style: TextStyle(fontSize: 14, color: cs.outline)),
          ],
        ),
      );
    }

    final isTable = RssrApp.of(context).viewMode == ViewMode.table;

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
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
