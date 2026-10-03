enum PaymentStatus {
  pending,
  approved,
  rejected,
}

class PaymentTransaction {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String paymentMethod;
  final String reason;
  final String? bookTitle;
  final String transactionId;
  final DateTime paymentDate;
  final PaymentStatus status;
  final String? receiptUrl;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  PaymentTransaction({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.paymentMethod,
    required this.reason,
    this.bookTitle,
    required this.transactionId,
    required this.paymentDate,
    required this.status,
    this.receiptUrl,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      reason: json['reason'] as String,
      bookTitle: json['bookTitle'] as String?,
      transactionId: json['transactionId'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      receiptUrl: json['receiptUrl'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'reason': reason,
      'bookTitle': bookTitle,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status.name,
      'receiptUrl': receiptUrl,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PaymentTransaction copyWith({
    String? id,
    String? memberId,
    String? memberName,
    double? amount,
    String? paymentMethod,
    String? reason,
    String? bookTitle,
    String? transactionId,
    DateTime? paymentDate,
    PaymentStatus? status,
    String? receiptUrl,
    String? verifiedBy,
    DateTime? verifiedAt,
    DateTime? createdAt,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reason: reason ?? this.reason,
      bookTitle: bookTitle ?? this.bookTitle,
      transactionId: transactionId ?? this.transactionId,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedAmount => 'LKR ${amount.toStringAsFixed(2)}';

  String get statusLabel {
    switch (status) {
      case PaymentStatus.pending:
        return 'PAYMENT UNDER REVIEW';
      case PaymentStatus.approved:
        return 'PAYMENT VERIFIED';
      case PaymentStatus.rejected:
        return 'PAYMENT REJECTED';
    }
  }

  String get statusShortLabel {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.approved:
        return 'Approved';
      case PaymentStatus.rejected:
        return 'Rejected';
    }
  }
}
