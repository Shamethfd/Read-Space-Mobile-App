import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes;
import 'package:read_space/models/notice.dart';
import 'package:read_space/services/notification_service.dart';
import 'package:read_space/widgets/notice_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  List<Notice> _notices = [];
  List<Notice> _unreadNotices = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_currentUserId == null) {
      setState(() {
        _errorMessage = 'Please log in to view notifications';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notices = await _notificationService.getUserNotifications();
      final unreadNotices = await _notificationService.getUnreadNotices(_currentUserId!);
      
      if (mounted) {
        setState(() {
          _notices = notices;
          _unreadNotices = unreadNotices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(Notice notice) async {
    if (_currentUserId == null) return;
    await _notificationService.markAsRead(_currentUserId!, notice.id);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId == null) return;
    await _notificationService.markAllAsRead(_currentUserId!);
    await _loadNotifications();
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
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (_unreadNotices.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadNotifications,
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
            const Icon(Icons.notifications_none_outlined, size: 48, color: AppTheme.secondaryText),
            const SizedBox(height: 16),
            Text(
              'No notifications available',
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
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          final notice = _notices[index];
          final isUnread = _unreadNotices.any((n) => n.id == notice.id);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NoticeCard(
              notice: notice,
              isUnread: isUnread,
              onTap: () async {
                await _markAsRead(notice);
                if (mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.noticeDetails,
                    arguments: notice,
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
