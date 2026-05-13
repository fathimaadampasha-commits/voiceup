import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// Anatomy locked: circular avatar 40px + Column(anonymous name bold, subtitle muted)
// + trailing notification icon

class GreetingRowWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const GreetingRowWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    final username = userData['username'] as String;
    final avatarColors = _avatarColors(userData['avatarSeed'] as String);

    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: avatarColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.neonPurple.withAlpha(102),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              username[0].toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$greeting 👋',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                username,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.glassSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.neonGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Search
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: const Center(
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _avatarColors(String seed) {
    final hash = seed.codeUnits.fold(0, (prev, el) => prev + el);
    final palettes = [
      [AppTheme.neonPurple, const Color(0xFF3B1F8C)],
      [AppTheme.neonGreen, const Color(0xFF064E3B)],
      [AppTheme.neonPink, const Color(0xFF831843)],
      [const Color(0xFF3B82F6), const Color(0xFF1E3A8A)],
      [const Color(0xFFF59E0B), const Color(0xFF78350F)],
    ];
    return palettes[hash % palettes.length];
  }
}
