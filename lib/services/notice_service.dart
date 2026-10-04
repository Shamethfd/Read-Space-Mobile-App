import '../models/notice.dart';
import 'firestore_service.dart';

class NoticeService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<Notice>> getAllNotices() async {
    return await _firestoreService.getAllNoticesStream().first;
  }

  Future<List<Notice>> getPublishedNotices() async {
    return await _firestoreService.getActiveNoticesStream().first;
  }

  Future<Notice?> getNoticeById(String id) async {
    final notices = await getAllNotices();
    try {
      return notices.firstWhere((notice) => notice.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Notice> createNotice(Notice notice) async {
    await _firestoreService.addNotice(notice);
    return notice;
  }

  Future<Notice> updateNotice(Notice notice) async {
    await _firestoreService.updateNotice(notice.id, notice.toJson());
    return notice;
  }

  Future<void> deleteNotice(String id) async {
    await _firestoreService.deleteNotice(id);
  }

  Future<List<Notice>> getNoticesByCreator(String createdBy) async {
    final notices = await getAllNotices();
    return notices.where((notice) => notice.createdBy == createdBy).toList();
  }

  Future<List<Notice>> getNoticesByCategory(NoticeCategory category) async {
    final notices = await getAllNotices();
    return notices.where((notice) => notice.category == category).toList();
  }
}
