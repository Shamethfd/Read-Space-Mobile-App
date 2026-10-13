enum HoldStatus {
  pending,
  ready,
  cancelled,
}

class Hold {
  final String id;
  final String bookId;
  final String userId;
  final DateTime createdAt;
  final HoldStatus holdStatus;
  final int queuePosition;
  final DateTime? readyAt;
  final DateTime? expiresAt;

  Hold({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.createdAt,
    required this.holdStatus,
    required this.queuePosition,
    this.readyAt,
    this.expiresAt,
  });

  factory Hold.fromJson(Map<String, dynamic> json) {
    final statusString = json['holdStatus'] as String?;
    HoldStatus status;
    
    try {
      status = HoldStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () {
          // Handle legacy 'expired' status by treating it as cancelled
          if (statusString == 'expired') {
            return HoldStatus.cancelled;
          }
          return HoldStatus.pending;
        },
      );
    } catch (e) {
      status = HoldStatus.pending;
    }
    
    return Hold(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      holdStatus: status,
      queuePosition: json['queuePosition'] as int? ?? 0,
      readyAt: json['readyAt'] != null
          ? DateTime.parse(json['readyAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'holdStatus': holdStatus.name,
      'queuePosition': queuePosition,
      'readyAt': readyAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

class DuplicateHoldException implements Exception {
  final String message;
  DuplicateHoldException(this.message);

  @override
  String toString() => message;
}
