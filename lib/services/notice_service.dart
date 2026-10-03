import '../models/notice.dart';

class NoticeService {
  // TODO: Replace with actual API calls
  // This is a placeholder for backend integration

  // In-memory storage for demo purposes
  final List<Notice> _notices = [];

  Future<List<Notice>> getAllNotices() async {
    // TODO: Replace with GET /notices API call
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_notices);
  }

  Future<List<Notice>> getPublishedNotices() async {
    // TODO: Replace with GET /notices?status=published API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _notices.where((notice) => notice.isActive).toList();
  }

  Future<Notice?> getNoticeById(String id) async {
    // TODO: Replace with GET /notices/:id API call
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _notices.firstWhere((notice) => notice.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Notice> createNotice(Notice notice) async {
    // TODO: Replace with POST /notices API call
    await Future.delayed(const Duration(milliseconds: 800));
    _notices.add(notice);
    return notice;
  }

  Future<Notice> updateNotice(Notice notice) async {
    // TODO: Replace with PUT /notices/:id API call
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _notices.indexWhere((n) => n.id == notice.id);
    if (index != -1) {
      _notices[index] = notice;
    }
    return notice;
  }

  Future<void> deleteNotice(String id) async {
    // TODO: Replace with DELETE /notices/:id API call
    await Future.delayed(const Duration(milliseconds: 500));
    _notices.removeWhere((notice) => notice.id == id);
  }

  Future<List<Notice>> getNoticesByCreator(String createdBy) async {
    // TODO: Replace with GET /notices?createdBy=userId API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _notices.where((notice) => notice.createdBy == createdBy).toList();
  }

  Future<List<Notice>> getNoticesByCategory(NoticeCategory category) async {
    // TODO: Replace with GET /notices?category=category API call
    await Future.delayed(const Duration(milliseconds: 500));
    return _notices.where((notice) => notice.category == category).toList();
  }
}
