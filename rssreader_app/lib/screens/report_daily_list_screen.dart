import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import 'report_screen.dart';

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
            const Text('Reports', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: cs.error)))
              : _reports.isEmpty
                  ? Center(child: Text('No reports yet', style: TextStyle(color: cs.outline)))
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
                            ? r.summary!.substring(0, r.summary!.length.clamp(0, 200))
                            : null;
                        return ListTile(
                          leading: Icon(Icons.article_outlined, size: 20, color: cs.outline),
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
