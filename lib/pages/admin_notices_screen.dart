import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes;
import 'package:read_space/models/notice.dart';
import 'package:read_space/services/notice_service.dart';
import 'package:read_space/widgets/admin_notice_card.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final _noticeService = NoticeService();
  List<Notice> _notices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notices = await _noticeService.getAllNotices();
      if (mounted) {
        setState(() {
          _notices = notices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load notices';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotice(Notice notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice?'),
        content: const Text(
          'Are you sure you want to delete this notice? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _noticeService.deleteNotice(notice.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notice deleted successfully.'),
              backgroundColor: AppTheme.success,
            ),
          );
          _loadNotices();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete notice.'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Notice Management',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.publishNotice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Publish New Notice',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.secondaryText),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: AppTheme.secondaryText),
            const SizedBox(height: 16),
            Text(
              'No notices available',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          final notice = _notices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminNoticeCard(
              notice: notice,
              onEdit: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editNotice,
                  arguments: notice,
                );
              },
              onDelete: () => _deleteNotice(notice),
            ),
          );
        },
      ),
    );
  }
}
