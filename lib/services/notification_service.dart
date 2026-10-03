import '../models/notice.dart';
import '../models/user_notice_read_status.dart';
import 'notice_service.dart';

class NotificationService {
  final NoticeService _noticeService = NoticeService();

  // TODO: Replace with actual API calls
  // This is a placeholder for backend integration

  // In-memory storage for demo purposes
  final List<UserNoticeReadStatus> _readStatuses = [];

  // Get all published notices for the user
  Future<List<Notice>> getUserNotifications() async {
    // TODO: Replace with GET /notifications API call
    return await _noticeService.getPublishedNotices();
  }

  // Get unread notices for a specific user
  Future<List<Notice>> getUnreadNotices(String userId) async {
    // TODO: Replace with GET /notifications?userId=userId&unread=true API call
    final allNotices = await _noticeService.getPublishedNotices();
    final readNoticeIds = _readStatuses
        .where((status) => status.userId == userId)
        .map((status) => status.noticeId)
        .toSet();

    return allNotices.where((notice) => !readNoticeIds.contains(notice.id)).toList();
  }

  // Get count of unread notices for a user
  Future<int> getUnreadCount(String userId) async {
    // TODO: Replace with GET /notifications/unread-count API call
    final unreadNotices = await getUnreadNotices(userId);
    return unreadNotices.length;
  }

  // Mark a notice as read for a user
  Future<void> markAsRead(String userId, String noticeId) async {
    // TODO: Replace with PUT /notifications/:noticeId/read API call
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if already marked as read
    final existing = _readStatuses.firstWhere(
      (status) => status.userId == userId && status.noticeId == noticeId,
      orElse: () => UserNoticeReadStatus(
        userId: userId,
        noticeId: noticeId,
        readAt: DateTime.now(),
      ),
    );

    if (!_readStatuses.contains(existing)) {
      _readStatuses.add(existing);
    }
  }

  // Mark all notices as read for a user
  Future<void> markAllAsRead(String userId) async {
    // TODO: Replace with PUT /notifications/read-all API call
    await Future.delayed(const Duration(milliseconds: 500));

    final allNotices = await _noticeService.getPublishedNotices();
    for (final notice in allNotices) {
      await markAsRead(userId, notice.id);
    }
  }

  // Check if a notice is read by a user
  Future<bool> isNoticeRead(String userId, String noticeId) async {
    // TODO: Replace with GET /notifications/:noticeId/read-status API call
    return _readStatuses.any(
      (status) => status.userId == userId && status.noticeId == noticeId,
    );
  }
}
