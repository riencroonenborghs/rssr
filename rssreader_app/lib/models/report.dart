class Report {
  final int id;
  final List<String> keywords;
  final String reportType;
  final DateTime? lastGeneratedAt;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.keywords,
    required this.reportType,
    this.lastGeneratedAt,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      keywords: (json['keywords'] as List<dynamic>? ?? [])
          .map((k) => k.toString())
          .toList(),
      reportType: json['report_type'] as String? ?? 'daily',
      lastGeneratedAt: json['last_generated_at'] != null
          ? DateTime.parse(json['last_generated_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class DailyReport {
  final int id;
  final String? summary;
  final DateTime createdAt;
  final List<String> keywords;

  const DailyReport({
    required this.id,
    this.summary,
    required this.createdAt,
    required this.keywords,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    final report = json['report'] as Map<String, dynamic>? ?? {};
    final keywords = (report['keywords'] as List<dynamic>? ?? [])
        .map((k) => k.toString())
        .toList();
    return DailyReport(
      id: json['id'] as int,
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      keywords: keywords,
    );
  }
}
