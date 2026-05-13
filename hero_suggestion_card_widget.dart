import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/status_badge_widget.dart';

// Anatomy locked: status chip top-left + date badge top-right + title large
// + progress bar row + CTA button full-width inside card
// V2 Glassmorphism Card — LOCKED

class HeroSuggestionCardWidget extends StatelessWidget {
  final Map<String, dynamic> suggestion;

  const HeroSuggestionCardWidget({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final status = _parseStatus(suggestion['status'] as String);
    final upvotes = suggestion['upvotes'] as int;
    final progress = suggestion['lessonProgress'] as double;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonPurple.withAlpha(38),
                AppTheme.neonGreen.withAlpha(20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neonPurple.withAlpha(64),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: status + date badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadgeWidget(status: status),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: AppTheme.neonGreen,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Your Post',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                suggestion['title'] as String,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${suggestion['category']} • ${suggestion['daysAgo']} days ago',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              // Upvote progress bar
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_rounded,
                    color: AppTheme.neonGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$upvotes upvotes',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}% support',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.glassSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.neonGreen,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 14),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to suggestion detail
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('View Progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
