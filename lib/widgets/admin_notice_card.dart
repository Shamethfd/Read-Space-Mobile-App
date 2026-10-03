import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/notice.dart';

class AdminNoticeCard extends StatelessWidget {
  const AdminNoticeCard({
    super.key,
    required this.notice,
    this.onEdit,
    this.onDelete,
  });

  final Notice notice;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(status: notice.status),
              const SizedBox(width: 8),
              _CategoryPill(category: notice.category),
              const Spacer(),
              _PriorityIndicator(priority: notice.priority),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notice.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'By ${notice.createdBy}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(notice.publishedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.secondaryText,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppTheme.primaryBlue,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppTheme.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getShortDescription(String description) {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final NoticeStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case NoticeStatus.draft:
        color = AppTheme.secondaryText;
        label = 'Draft';
        break;
      case NoticeStatus.published:
        color = AppTheme.success;
        label = 'Published';
        break;
      case NoticeStatus.expired:
        color = AppTheme.secondaryText;
        label = 'Expired';
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
