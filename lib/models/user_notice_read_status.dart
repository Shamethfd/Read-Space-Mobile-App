class UserNoticeReadStatus {
  final String userId;
  final String noticeId;
  final DateTime readAt;

  UserNoticeReadStatus({
    required this.userId,
    required this.noticeId,
    required this.readAt,
  });

  factory UserNoticeReadStatus.fromJson(Map<String, dynamic> json) {
    return UserNoticeReadStatus(
      userId: json['userId'] as String,
      noticeId: json['noticeId'] as String,
      readAt: DateTime.parse(json['readAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'noticeId': noticeId,
      'readAt': readAt.toIso8601String(),
    };
  }
}
