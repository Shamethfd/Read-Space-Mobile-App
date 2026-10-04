enum FineStatus {
  pending,
  paid,
  waived,
  overdue,
}

class Fine {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String? bookTitle;
  final double amount;
  final String reason;
  final DateTime dueDate;
  final FineStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? paymentId;
  final String? notes;

  Fine({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    this.bookTitle,
    required this.amount,
    required this.reason,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.paymentId,
    this.notes,
  });

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String?,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: FineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FineStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      paymentId: json['paymentId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'amount': amount,
      'reason': reason,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentId': paymentId,
      'notes': notes,
    };
  }

  Fine copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bookId,
    String? bookTitle,
    double? amount,
    String? reason,
    DateTime? dueDate,
    FineStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentId,
    String? notes,
  }) {
    return Fine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentId: paymentId ?? this.paymentId,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status != FineStatus.paid;
}
