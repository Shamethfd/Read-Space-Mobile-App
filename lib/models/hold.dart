enum HoldStatus {
  pending,
  ready,
  expired,
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

  Hold copyWith({
    String? id,
    String? bookId,
    String? userId,
    DateTime? createdAt,
    HoldStatus? holdStatus,
    int? queuePosition,
    DateTime? readyAt,
    DateTime? expiresAt,
  }) {
    return Hold(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      holdStatus: holdStatus ?? this.holdStatus,
      queuePosition: queuePosition ?? this.queuePosition,
      readyAt: readyAt ?? this.readyAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory Hold.fromJson(Map<String, dynamic> json) {
    return Hold(
      id: json['id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      holdStatus: HoldStatus.values.firstWhere(
        (e) => e.name == json['holdStatus'],
        orElse: () => HoldStatus.pending,
      ),
      queuePosition: json['queuePosition'] is int
          ? json['queuePosition'] as int
          : (json['queuePosition'] as num?)?.toInt() ?? 0,
      readyAt: json['readyAt'] != null ? _parseDateTime(json['readyAt']) : null,
      expiresAt: json['expiresAt'] != null ? _parseDateTime(json['expiresAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
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
