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
