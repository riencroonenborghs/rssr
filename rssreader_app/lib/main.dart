import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/sign_in_screen.dart';
import 'screens/unread_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RssrApp());
}

class RssrApp extends StatefulWidget {
  const RssrApp({super.key});

  static RssrAppState of(BuildContext context) =>
      context.findAncestorStateOfType<RssrAppState>()!;

  @override
  State<RssrApp> createState() => RssrAppState();
}

class RssrAppState extends State<RssrApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);
  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSS Reader',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const _AuthGate(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final primary = isDark ? const Color(0xFF6B9FE4) : const Color(0xFF2D4A8A);
  final onPrimary = isDark ? const Color(0xFF0D1B33) : const Color(0xFFF0F4FC);
  final surface = isDark ? const Color(0xFF111318) : const Color(0xFFF5F7FC);
  final onSurface = isDark ? const Color(0xFFE2E6F0) : const Color(0xFF1A1C22);
  final secondaryContainer =
      isDark ? const Color(0xFF1E3054) : const Color(0xFFB8CCEE);
  final onSecondaryContainer =
      isDark ? const Color(0xFFB8CCEE) : const Color(0xFF1A2744);
  final outline = isDark ? const Color(0xFF5A6478) : const Color(0xFF7A8499);
  final dividerColor =
      isDark ? const Color(0xFF252830) : const Color(0xFFD8DEF0);
  final scaffoldBg =
      isDark ? const Color(0xFF0D0F14) : const Color(0xFFF0F2F8);
  final appBarBg =
      isDark ? const Color(0xFF161A24) : const Color(0xFF2D4A8A);
  final appBarFg = isDark ? const Color(0xFFE2E6F0) : const Color(0xFFF0F4FC);
  final inputFill = isDark ? const Color(0xFF1C2030) : Colors.white;
  final inputBorder =
      isDark ? const Color(0xFF2E3650) : const Color(0xFFBBC4D8);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer:
          isDark ? const Color(0xFF1E3054) : const Color(0xFF4169B8),
      onPrimaryContainer:
          isDark ? const Color(0xFF6B9FE4) : const Color(0xFFF0F4FC),
      secondary: isDark ? const Color(0xFF4A72B8) : const Color(0xFF5A7EC0),
      onSecondary: onPrimary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: isDark ? const Color(0xFFD4A853) : const Color(0xFF8B5E14),
      onTertiary: isDark ? const Color(0xFF1A0E00) : const Color(0xFFF0F4FC),
      tertiaryContainer:
          isDark ? const Color(0xFF3A2B06) : const Color(0xFFEDD9A3),
      onTertiaryContainer:
          isDark ? const Color(0xFFEDD9A3) : const Color(0xFF3A2B06),
      error: const Color(0xFFCF6679),
      onError: isDark ? const Color(0xFF1A0005) : const Color(0xFFF0F4FC),
      errorContainer:
          isDark ? const Color(0xFF3B0010) : const Color(0xFFF9DEDC),
      onErrorContainer:
          isDark ? const Color(0xFFCF6679) : const Color(0xFF410E0B),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? const Color(0xFF1C2030) : const Color(0xFFE0E6F4),
      outline: outline,
    ),
    scaffoldBackgroundColor: scaffoldBg,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBg,
      foregroundColor: appBarFg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: appBarFg,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: appBarFg),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.light,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: isDark ? const Color(0xFF13161F) : const Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCF6679)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
      ),
      labelStyle: TextStyle(color: outline),
      floatingLabelStyle: TextStyle(color: primary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        elevation: 0,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: outline,
      textColor: onSurface,
      selectedColor: primary,
      selectedTileColor: isDark
          ? const Color(0xFF1E2E50)
          : const Color(0xFFE8EEF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1E2A44) : const Color(0xFF1A2744),
      contentTextStyle: const TextStyle(color: Color(0xFFF0F4FC)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getSessionCookie(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        final cookie = snapshot.data;
        if (cookie != null) return UnreadScreen(cookie: cookie);
        return const SignInScreen();
      },
    );
  }
}
