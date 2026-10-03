import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/notice.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    this.isUnread = false,
    this.onTap,
  });

  final Notice notice;
  final bool isUnread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppTheme.primaryBlue.withValues(alpha: 0.03)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread
                ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread) ...[
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryPill(category: notice.category),
                      const SizedBox(width: 8),
                      _PriorityIndicator(priority: notice.priority),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notice.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getShortDescription(notice.description),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notice.publishedAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    if (description.length <= 80) return description;
    return '${description.substring(0, 80)}...';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});

  final NoticeCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryLabel(category),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  String _getCategoryLabel(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.general:
        return 'General';
      case NoticeCategory.important:
        return 'Important';
      case NoticeCategory.library:
        return 'Library';
      case NoticeCategory.events:
        return 'Events';
      case NoticeCategory.maintenance:
        return 'Maintenance';
      case NoticeCategory.academic:
        return 'Academic';
    }
  }
}

class _PriorityIndicator extends StatelessWidget {
  const _PriorityIndicator({required this.priority});

  final NoticePriority priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case NoticePriority.normal:
        color = AppTheme.secondaryText;
        label = 'Normal';
        break;
      case NoticePriority.important:
        color = const Color(0xFFF59E0B);
        label = 'Important';
        break;
      case NoticePriority.urgent:
        color = AppTheme.red;
        label = 'Urgent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
