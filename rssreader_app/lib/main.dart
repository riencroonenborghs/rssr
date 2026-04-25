import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/sign_in_screen.dart';
import 'screens/unread_screen.dart';
import 'services/auth_service.dart';

enum ViewMode { cards, table }

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
  ViewMode _viewMode = ViewMode.cards;

  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);
  ThemeMode get themeMode => _themeMode;

  ViewMode get viewMode => _viewMode;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('view_mode');
    if (stored != null && mounted) {
      setState(() => _viewMode = ViewMode.values.byName(stored));
    }
  }

  void setViewMode(ViewMode mode) {
    setState(() => _viewMode = mode);
    SharedPreferences.getInstance().then((p) => p.setString('view_mode', mode.name));
  }

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

  // Paper palette
  final scaffoldBg  = isDark ? const Color(0xFF1A1714) : const Color(0xFFFFFFFF);
  final surface     = isDark ? const Color(0xFF221F1B) : const Color(0xFFFFFFFF);
  final cardBg      = isDark ? const Color(0xFF2A2622) : const Color(0xFFFFFFFF);
  final onSurface   = isDark ? const Color(0xFFEDE8E1) : const Color(0xFF1C1917);
  final outline     = isDark ? const Color(0xFF7A7068) : const Color(0xFF9C8F82);
  final divider     = isDark ? const Color(0xFF2A2F2A) : const Color(0xFFE4EBE4);
  final primary     = isDark ? const Color(0xFF7FAF82) : const Color(0xFF3D6B42);
  final onPrimary   = isDark ? const Color(0xFF0F1A10) : const Color(0xFFF4FAF4);
  final inputFill   = isDark ? const Color(0xFF212621) : const Color(0xFFFFFFFF);
  final inputBorder = isDark ? const Color(0xFF324032) : const Color(0xFFBFCEBF);

  final baseTextTheme = ThemeData.light().textTheme;
  final textTheme = baseTextTheme.copyWith(
    displayLarge:  baseTextTheme.displayLarge?.copyWith(color: onSurface, height: 1.2),
    displayMedium: baseTextTheme.displayMedium?.copyWith(color: onSurface, height: 1.2),
    displaySmall:  baseTextTheme.displaySmall?.copyWith(color: onSurface, height: 1.2),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700, height: 1.25),
    headlineMedium:baseTextTheme.headlineMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w700, height: 1.25),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w700, height: 1.3),
    titleLarge:    baseTextTheme.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    titleMedium:   baseTextTheme.titleMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
    titleSmall:    baseTextTheme.titleSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
    bodyLarge:     baseTextTheme.bodyLarge?.copyWith(color: onSurface, height: 1.6, fontSize: 16),
    bodyMedium:    baseTextTheme.bodyMedium?.copyWith(color: onSurface, height: 1.55, fontSize: 14),
    bodySmall:     baseTextTheme.bodySmall?.copyWith(color: outline, height: 1.5, fontSize: 12),
    labelLarge:    baseTextTheme.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    labelMedium:   baseTextTheme.labelMedium?.copyWith(color: outline, letterSpacing: 0.3),
    labelSmall:    baseTextTheme.labelSmall?.copyWith(color: outline, letterSpacing: 0.4),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    textTheme: textTheme,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isDark ? const Color(0xFF1E3320) : const Color(0xFFD6EBD8),
      onPrimaryContainer: isDark ? const Color(0xFF7FAF82) : const Color(0xFF1A3D1E),
      secondary: isDark ? const Color(0xFF7A9C7C) : const Color(0xFF4A6B4D),
      onSecondary: isDark ? const Color(0xFF0F1A10) : const Color(0xFFF4FAF4),
      secondaryContainer: isDark ? const Color(0xFF1E2E1F) : const Color(0xFFE4EFE4),
      onSecondaryContainer: isDark ? const Color(0xFFD6EBD8) : const Color(0xFF1A2D1C),
      tertiary: isDark ? const Color(0xFF8BAF8E) : const Color(0xFF3A5C3D),
      onTertiary: isDark ? const Color(0xFF0F1A10) : const Color(0xFFF4FAF4),
      tertiaryContainer: isDark ? const Color(0xFF1A2D1C) : const Color(0xFFCFE8D1),
      onTertiaryContainer: isDark ? const Color(0xFFCFE8D1) : const Color(0xFF0D1F0F),
      error: isDark ? const Color(0xFFCF7B6F) : const Color(0xFFB3261E),
      onError: isDark ? const Color(0xFF1A0005) : const Color(0xFFFBF9F5),
      errorContainer: isDark ? const Color(0xFF3B1510) : const Color(0xFFF9DEDC),
      onErrorContainer: isDark ? const Color(0xFFCF7B6F) : const Color(0xFF410E0B),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isDark ? const Color(0xFF312C27) : const Color(0xFFEDE4D8),
      outline: outline,
    ),
    scaffoldBackgroundColor: scaffoldBg,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBg,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
      iconTheme: IconThemeData(color: onSurface),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: isDark ? const Color(0xFF171C17) : const Color(0xFFF4FAF4),
      surfaceTintColor: Colors.transparent,
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFFCF7B6F) : const Color(0xFFB3261E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFFCF7B6F) : const Color(0xFFB3261E), width: 1.5),
      ),
      labelStyle: TextStyle(color: outline),
      floatingLabelStyle: TextStyle(color: primary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        elevation: 0,
      ),
    ),
    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: outline,
      textColor: onSurface,
      selectedColor: primary,
      selectedTileColor: isDark ? const Color(0xFF1E3320) : const Color(0xFFD6EBD8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? const Color(0xFF1E3320) : const Color(0xFF1A3D1E),
      contentTextStyle: TextStyle(color: isDark ? const Color(0xFFD6EBD8) : const Color(0xFFF4FAF4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    // expose cardBg for widgets that need it via surfaceContainerLow
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: divider, width: 1),
      ),
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
