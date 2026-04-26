import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL');
  static const _cookieKey = 'session_cookie';

  Future<({String csrfToken, String cookie})> _fetchCsrf() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/sign_in'),
      headers: {'Accept': 'text/html'},
    );
    final rawCookie = response.headers['set-cookie'] ?? '';
    final cookie = rawCookie.split(';').first;
    final match = RegExp(r'<meta name="csrf-token" content="([^"]+)"')
        .firstMatch(response.body);
    final csrfToken = match?.group(1) ?? '';
    return (csrfToken: csrfToken, cookie: cookie);
  }

  Future<bool> signIn(String email, String password) async {
    final csrf = await _fetchCsrf();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/users/sign_in'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': csrf.csrfToken,
        'Cookie': csrf.cookie,
      },
      body: jsonEncode({'user': {'email': email, 'password': password}}),
    );

    if (response.statusCode == 200) {
      final rawCookie = response.headers['set-cookie'] ?? '';
      final sessionCookie = rawCookie.split(';').first;
      if (sessionCookie.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cookieKey, sessionCookie);
        return true;
      }
    }
    return false;
  }

  Future<String?> getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }
}
