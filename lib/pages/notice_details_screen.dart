import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/notice.dart';

class NoticeDetailsScreen extends StatefulWidget {
  const NoticeDetailsScreen({super.key});

  @override
  State<NoticeDetailsScreen> createState() => _NoticeDetailsScreenState();
}

class _NoticeDetailsScreenState extends State<NoticeDetailsScreen> {
  Notice? _notice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notice == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Notice?;
      if (args != null) {
        setState(() => _notice = args);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_notice == null) {
      return Scaffold(
        backgroundColor: AppTheme.pageBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Notice Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildCategoryAndPriority(),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildEventDate(),
            const SizedBox(height: 20),
            _buildExpiryDate(),
            const SizedBox(height: 20),
            _buildAttachment(),
            const SizedBox(height: 20),
            _buildMetaInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      _notice!.title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildCategoryAndPriority() {
    return Row(
      children: [
        _CategoryPill(category: _notice!.category),
        const SizedBox(width: 8),
        _PriorityIndicator(priority: _notice!.priority),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _notice!.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDate() {
    if (_notice!.eventDate == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Date',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_notice!.eventDate!.day}/${_notice!.eventDate!.month}/${_notice!.eventDate!.year}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryDate() {
    if (_notice!.expiryDate == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: _notice!.isExpired ? AppTheme.red : AppTheme.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expiry Date',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_notice!.expiryDate!.day}/${_notice!.expiryDate!.month}/${_notice!.expiryDate!.year}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _notice!.isExpired ? AppTheme.red : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment() {
    if (_notice!.attachmentUrl == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attachment',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View attached file',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Published by ${_notice!.createdBy}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'on ${_notice!.publishedAt.day}/${_notice!.publishedAt.month}/${_notice!.publishedAt.year}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getCategoryLabel(category),
        style: GoogleFonts.poppins(
          fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
