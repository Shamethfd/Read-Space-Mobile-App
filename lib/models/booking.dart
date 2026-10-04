enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String seatId;
  final String resourceId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? notes;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.seatId,
    required this.resourceId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      seatId: json['seatId'] as String,
      resourceId: json['resourceId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'seatId': seatId,
      'resourceId': resourceId,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? seatId,
    String? resourceId,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? cancelledAt,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      seatId: seatId ?? this.seatId,
      resourceId: resourceId ?? this.resourceId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      notes: notes ?? this.notes,
    );
  }
}
