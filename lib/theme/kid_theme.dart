import 'package:flutter/material.dart';

/// Shared kindergarten look: warm paper, one ink colour, and soft subject colours.
class KidColors {
  static const cream = Color(0xFFFFF6EE);
  static const ink = Color(0xFF3B2A5A);
  static const muted = Color(0xFF7D6E90);
  static const plum = Color(0xFF6B4EFF);
  static const berry = Color(0xFFFF6B93);
  static const sun = Color(0xFFFFB020);
  static const leaf = Color(0xFF2EBE7B);
  static const sky = Color(0xFF3D9BE9);
  static const coral = Color(0xFFFF8A5B);
}

class KidTheme {
  static ThemeData data() {
    final scheme = ColorScheme.fromSeed(
      seedColor: KidColors.plum,
      primary: KidColors.plum,
      surface: KidColors.cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: KidColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: KidColors.cream,
        foregroundColor: KidColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: KidColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KidColors.plum,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(color: KidColors.ink, fontWeight: FontWeight.w600),
        side: BorderSide(color: KidColors.plum.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: KidColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class KidTile extends StatelessWidget {
  final String title;
  final String emoji;
  final Color accent;
  final VoidCallback onTap;
  final String? subtitle;

  const KidTile({
    super.key,
    required this.title,
    required this.emoji,
    required this.accent,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 34)),
                    ),
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: KidColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: KidColors.muted, fontSize: 12, height: 1.2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KidLevelTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final bool unlocked;
  final Color accent;
  final VoidCallback? onTap;

  const KidLevelTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.unlocked,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wash = unlocked ? accent.withValues(alpha: 0.12) : const Color(0xFFE7E2EA);
    final ink = unlocked ? KidColors.ink : KidColors.muted;
    return Material(
      color: wash,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: ink, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KidIntro extends StatelessWidget {
  final String emoji;
  final String title;
  final String message;

  const KidIntro({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: KidColors.ink)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(color: KidColors.muted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
