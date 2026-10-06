import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice.dart';
import '../models/user_notice_read_status.dart';
import 'notice_service.dart';

class NotificationService {
  final NoticeService _noticeService = NoticeService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all published notices for the user
  Future<List<Notice>> getUserNotifications() async {
    try {
      return await _noticeService.getPublishedNotices();
    } on FirebaseException {
      return [];
    }
  }

  // Get unread notices for a specific user
  Future<List<Notice>> getUnreadNotices(String userId) async {
    try {
      final allNotices = await _noticeService.getPublishedNotices();

      final readStatusesSnapshot = await _firestore
          .collection('userNoticeReadStatus')
          .where('userId', isEqualTo: userId)
          .get();

      final readNoticeIds = readStatusesSnapshot.docs
          .map((doc) => doc.data()['noticeId'] as String)
          .toSet();

      return allNotices
          .where((notice) => !readNoticeIds.contains(notice.id))
          .toList();
    } on FirebaseException {
      return [];
    }
  }

  // Get count of unread notices for a user
  Future<int> getUnreadCount(String userId) async {
    final unreadNotices = await getUnreadNotices(userId);
    return unreadNotices.length;
  }

  // Mark a notice as read for a user
  Future<void> markAsRead(String userId, String noticeId) async {
    final readStatus = UserNoticeReadStatus(
      userId: userId,
      noticeId: noticeId,
      readAt: DateTime.now(),
    );

    await _firestore
        .collection('userNoticeReadStatus')
        .doc('$userId-$noticeId')
        .set(readStatus.toJson());
  }

  // Mark all notices as read for a user
  Future<void> markAllAsRead(String userId) async {
    final allNotices = await _noticeService.getPublishedNotices();
    final batch = _firestore.batch();
    
    for (final notice in allNotices) {
      final docRef = _firestore
          .collection('userNoticeReadStatus')
          .doc('$userId-${notice.id}');
      
      final readStatus = UserNoticeReadStatus(
        userId: userId,
        noticeId: notice.id,
        readAt: DateTime.now(),
      );
      
      batch.set(docRef, readStatus.toJson());
    }
    
    await batch.commit();
  }

  // Check if a notice is read by a user
  Future<bool> isNoticeRead(String userId, String noticeId) async {
    final doc = await _firestore
        .collection('userNoticeReadStatus')
        .doc('$userId-$noticeId')
        .get();
    
    return doc.exists;
  }
}
