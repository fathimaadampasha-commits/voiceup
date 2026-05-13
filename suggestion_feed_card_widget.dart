import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';

// V1 Rich Data Row — LOCKED
// Anatomy locked: category chip top + title + body excerpt
// + vote row (up/down/count) + status badge + timestamp
// V2 Glassmorphism Card — LOCKED

class SuggestionFeedCardWidget extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReport;

  const SuggestionFeedCardWidget({
    super.key,
    required this.suggestion,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final status = _parseStatus(suggestion['status'] as String);
    final isHot = suggestion['isHot'] as bool;
    final userVote = suggestion['userVote'] as String?;
    final upvotes = suggestion['upvotes'] as int;
    final downvotes = suggestion['downvotes'] as int;
    final category = suggestion['category'] as String;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHot
                  ? AppTheme.neonPurple.withAlpha(51)
                  : AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hot indicator strip
              if (isHot)
                Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.neonPurple, AppTheme.neonGreen],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: category + hot badge + status
                    Row(
                      children: [
                        _CategoryChip(category: category),
                        if (isHot) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.neonPurple.withAlpha(31),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppTheme.neonPurple.withAlpha(77),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 10,
                                  color: AppTheme.neonPurple,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Trending',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.neonPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        StatusBadgeWidget(status: status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      suggestion['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Body excerpt
                    Text(
                      suggestion['body'] as String,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Vote row + timestamp + report
                    Row(
                      children: [
                        _VoteButton(
                          icon: Icons.thumb_up_rounded,
                          outlinedIcon: Icons.thumb_up_outlined,
                          count: upvotes,
                          isActive: userVote == 'up',
                          activeColor: AppTheme.neonGreen,
                          onTap: onUpvote,
                        ),
                        const SizedBox(width: 8),
                        _VoteButton(
                          icon: Icons.thumb_down_rounded,
                          outlinedIcon: Icons.thumb_down_outlined,
                          count: downvotes,
                          isActive: userVote == 'down',
                          activeColor: AppTheme.error,
                          onTap: onDownvote,
                        ),
                        const Spacer(),
                        Text(
                          suggestion['timestamp'] as String,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onReport,
                          child: const Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SuggestionStatus _parseStatus(String s) {
    switch (s) {
      case 'approved':
        return SuggestionStatus.approved;
      case 'underReview':
        return SuggestionStatus.underReview;
      case 'implemented':
        return SuggestionStatus.implemented;
      case 'rejected':
        return SuggestionStatus.rejected;
      default:
        return SuggestionStatus.pendingReview;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.border),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: config.text,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _ChipConfig _categoryConfig(String cat) {
    switch (cat) {
      case 'Academic':
        return _ChipConfig(
          bg: const Color(0x203B82F6),
          border: const Color(0x403B82F6),
          text: const Color(0xFF93C5FD),
        );
      case 'Campus':
        return _ChipConfig(
          bg: const Color(0x20F59E0B),
          border: const Color(0x40F59E0B),
          text: const Color(0xFFFBBF24),
        );
      case 'Tech':
        return _ChipConfig(
          bg: const Color(0x208B5CF6),
          border: const Color(0x408B5CF6),
          text: AppTheme.neonPurple,
        );
      case 'Welfare':
        return _ChipConfig(
          bg: const Color(0x2010B981),
          border: const Color(0x4010B981),
          text: AppTheme.neonGreen,
        );
      case 'Safety':
        return _ChipConfig(
          bg: const Color(0x20EF4444),
          border: const Color(0x40EF4444),
          text: AppTheme.error,
        );
      default:
        return _ChipConfig(
          bg: AppTheme.glassSurface,
          border: AppTheme.glassBorder,
          text: AppTheme.textMuted,
        );
    }
  }
}

class _ChipConfig {
  final Color bg;
  final Color border;
  final Color text;
  const _ChipConfig({
    required this.bg,
    required this.border,
    required this.text,
  });
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.outlinedIcon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withAlpha(38) : AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? activeColor : AppTheme.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : outlinedIcon,
              size: 14,
              color: isActive ? activeColor : AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
