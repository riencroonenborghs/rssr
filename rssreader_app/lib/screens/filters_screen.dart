import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/filter_service.dart';

class FiltersScreen extends StatefulWidget {
  final String cookie;

  const FiltersScreen({super.key, required this.cookie});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final _service = FilterService();
  final _scrollController = ScrollController();

  List<Filter> _filters = [];
  PaginationMeta? _meta;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;

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

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _page = 1; });
    try {
      final result = await _service.fetchFilters(widget.cookie, page: 1);
      if (!mounted) return;
      setState(() {
        _filters = result.filters;
        _meta = result.meta;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await _service.fetchFilters(widget.cookie, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _filters.addAll(result.filters);
        _meta = result.meta;
        _page++;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _delete(Filter filter, int index) async {
    setState(() => _filters.removeAt(index));
    try {
      await _service.deleteFilter(widget.cookie, filter.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _filters.insert(index, filter));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete filter')),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final filter = await showDialog<Filter>(
      context: context,
      builder: (ctx) => _AddFilterDialog(
        cookie: widget.cookie,
        service: _service,
      ),
    );
    if (filter != null) {
      setState(() => _filters.insert(0, filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Filters')),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _error != null
              ? _buildError(cs)
              : _filters.isEmpty
                  ? _buildEmpty(cs)
                  : _buildList(theme, cs, isDark),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 52, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'Could not load filters',
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_off_rounded, size: 52, color: cs.outline),
          const SizedBox(height: 16),
          Text('No filters', style: TextStyle(color: cs.outline)),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, ColorScheme cs, bool isDark) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _filters.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == _filters.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: cs.primary),
            ),
          );
        }

        final filter = _filters[index];
        return Dismissible(
          key: ValueKey(filter.id),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: cs.error,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) => _delete(filter, index),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2921) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  filter.comparison == 'includes'
                      ? Icons.text_fields_rounded
                      : Icons.label_outline_rounded,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        filter.comparison == 'includes' ? 'contains' : 'tagged with',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddFilterDialog extends StatefulWidget {
  final String cookie;
  final FilterService service;

  const _AddFilterDialog({required this.cookie, required this.service});

  @override
  State<_AddFilterDialog> createState() => _AddFilterDialogState();
}

class _AddFilterDialogState extends State<_AddFilterDialog> {
  final _valueController = TextEditingController();
  String _comparison = 'includes';
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _valueController.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Value is required');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final id = await widget.service.createFilter(widget.cookie, _comparison, value);
      if (!mounted) return;
      Navigator.of(context).pop(Filter(id: id, comparison: _comparison, value: value));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E2921) : Colors.white,
      title: Text('Add filter', style: TextStyle(color: cs.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type', style: theme.textTheme.labelSmall?.copyWith(color: cs.outline)),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'includes', label: Text('contains')),
              ButtonSegment(value: 'tagged', label: Text('tagged with')),
            ],
            selected: {_comparison},
            onSelectionChanged: (s) => setState(() => _comparison = s.first),
          ),
          const SizedBox(height: 16),
          Text('Value', style: theme.textTheme.labelSmall?.copyWith(color: cs.outline)),
          const SizedBox(height: 6),
          TextField(
            controller: _valueController,
            autofocus: true,
            style: TextStyle(color: cs.onSurface),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'e.g. flutter',
              hintStyle: TextStyle(color: cs.outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}
