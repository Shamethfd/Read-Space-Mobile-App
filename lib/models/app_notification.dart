class AppNotification {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final bool isRead;
  final String? reservationId;
  final String? bookId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    this.reservationId,
    this.bookId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: json['timestamp'] as String,
      isRead: json['isRead'] as bool,
      reservationId: json['reservationId'] as String?,
      bookId: json['bookId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
      'reservationId': reservationId,
      'bookId': bookId,
    };
  }
}
