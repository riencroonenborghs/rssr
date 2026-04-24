import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final appState = RssrApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionLabel('Appearance', theme, cs),
          _SettingsCard(
            isDark: isDark,
            cs: cs,
            child: Column(
              children: [
                _SettingsRow(
                  label: 'Theme',
                  cs: cs,
                  theme: theme,
                  child: _ThemeSegmented(
                    current: appState.themeMode,
                    onChanged: appState.setThemeMode,
                    cs: cs,
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Layout', theme, cs),
          _SettingsCard(
            isDark: isDark,
            cs: cs,
            child: _SettingsRow(
              label: 'View mode',
              cs: cs,
              theme: theme,
              child: _ViewModeSegmented(
                current: appState.viewMode,
                onChanged: appState.setViewMode,
                cs: cs,
                isDark: isDark,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;
  final ColorScheme cs;

  const _SectionLabel(this.text, this.theme, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.outline,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final ColorScheme cs;

  const _SettingsCard({required this.child, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B27) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;
  final ColorScheme cs;
  final ThemeData theme;

  const _SettingsRow({
    required this.label,
    required this.child,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  final ColorScheme cs;
  final bool isDark;
  final ThemeData theme;

  const _ThemeSegmented({
    required this.current,
    required this.onChanged,
    required this.cs,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
      (ThemeMode.system, Icons.brightness_auto_outlined, 'Auto'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2030) : const Color(0xFFF0F2F8),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final (mode, icon, label) = opt;
          final selected = current == mode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? const Color(0xFF2D4A8A) : cs.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: selected && !isDark
                    ? [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: selected ? Colors.white : cs.outline),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : cs.outline,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ViewModeSegmented extends StatelessWidget {
  final ViewMode current;
  final ValueChanged<ViewMode> onChanged;
  final ColorScheme cs;
  final bool isDark;
  final ThemeData theme;

  const _ViewModeSegmented({
    required this.current,
    required this.onChanged,
    required this.cs,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (ViewMode.cards, Icons.dashboard_outlined, 'Cards'),
      (ViewMode.table, Icons.view_list_outlined, 'Table'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2030) : const Color(0xFFF0F2F8),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final (mode, icon, label) = opt;
          final selected = current == mode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? const Color(0xFF2D4A8A) : cs.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: selected && !isDark
                    ? [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: selected ? Colors.white : cs.outline),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : cs.outline,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
