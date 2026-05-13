import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// Anatomy locked: 3 equal StatTile, each: icon top + number bold + label muted

class StatRowWidget extends StatelessWidget {
  final int totalSuggestions;
  final int totalUpvotes;
  final int streakDays;

  const StatRowWidget({
    super.key,
    required this.totalSuggestions,
    required this.totalUpvotes,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.forum_rounded,
            iconColor: AppTheme.neonPurple,
            value: '$totalSuggestions',
            label: 'Suggestions',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.thumb_up_rounded,
            iconColor: AppTheme.neonGreen,
            value: '$totalUpvotes',
            label: 'Upvotes',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFF59E0B),
            value: '${streakDays}d',
            label: 'Streak',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(31),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 16)),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
