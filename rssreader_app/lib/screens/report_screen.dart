import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  final String cookie;
  final int reportId;
  final DateTime? previewDate;

  const ReportScreen({
    super.key,
    required this.cookie,
    required this.reportId,
    this.previewDate,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _service = ReportService();
  DailyReport? _report;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final report = await _service.fetchDailyReport(widget.cookie, widget.reportId);
      if (!mounted) return;
      setState(() { _report = report; _loading = false; });
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
        title: const Text('Daily Report'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : _error != null
              ? _buildError(cs)
              : _buildContent(theme, cs, isDark),
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
              'Could not load report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
            const SizedBox(height: 6),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: cs.outline)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme cs, bool isDark) {
    final report = _report!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      children: [
        // Date + keywords row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: cs.outline),
            const SizedBox(width: 6),
            Text(
              _formatDate(report.createdAt),
              style: theme.textTheme.labelMedium?.copyWith(color: cs.outline),
            ),
          ],
        ),

        if (report.keywords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: report.keywords.map((kw) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? cs.primary.withValues(alpha: 0.15) : cs.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                kw,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? cs.primary : cs.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],

        if (report.summary != null && report.summary!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Divider(height: 1, color: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFDCEBDC)),
          const SizedBox(height: 24),
          MarkdownBody(
            data: report.summary!,
            onTapLink: (text, href, title) {
              if (href != null) launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
            },
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.85),
                height: 1.7,
                letterSpacing: 0.1,
              ),
              h1: theme.textTheme.headlineSmall?.copyWith(color: cs.onSurface),
              h2: theme.textTheme.titleLarge?.copyWith(color: cs.onSurface),
              h3: theme.textTheme.titleMedium?.copyWith(color: cs.onSurface),
              strong: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.7,
              ),
              em: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
              code: theme.textTheme.bodySmall?.copyWith(
                color: cs.primary,
                backgroundColor: isDark ? cs.primary.withValues(alpha: 0.1) : cs.primaryContainer,
                fontFamily: 'monospace',
              ),
              blockquote: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.65),
                fontStyle: FontStyle.italic,
                height: 1.7,
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: cs.primary.withValues(alpha: 0.5), width: 3),
                ),
                color: isDark ? cs.primary.withValues(alpha: 0.07) : cs.primaryContainer.withValues(alpha: 0.4),
              ),
              listBullet: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.85),
                height: 1.7,
              ),
              a: theme.textTheme.bodyMedium?.copyWith(
                color: cs.primary,
                height: 1.7,
                decoration: TextDecoration.underline,
                decorationColor: cs.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
