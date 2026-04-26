import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class ReportService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');

  Map<String, String> _headers(String cookie) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
      };

  Future<List<Report>> fetchReports(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>)
        .map((r) => Report.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<DailyReport>> fetchDailyReports(String cookie) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports/daily.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['reports'] as List<dynamic>)
        .map((r) => DailyReport.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<DailyReport> fetchDailyReport(String cookie, int id) async {
    final uri = Uri.parse('$_baseUrl/api/v1/reports/daily/$id.json');
    final response = await http.get(uri, headers: _headers(cookie));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DailyReport.fromJson(data['report'] as Map<String, dynamic>);
  }
}
