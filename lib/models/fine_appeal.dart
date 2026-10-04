enum AppealStatus {
  pending,
  approved,
  rejected,
  resolved,
  cancelled,
}

class FineAppeal {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String fineId;
  final String reason;
  final String? additionalNotes;
  final String? proofImageUrl;
  final String? proofDocumentUrl;
  final AppealStatus status;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? adminResponse;

  FineAppeal({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.fineId,
    required this.reason,
    this.additionalNotes,
    this.proofImageUrl,
    this.proofDocumentUrl,
    required this.status,
    required this.submittedAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.adminResponse,
  });

  factory FineAppeal.fromJson(Map<String, dynamic> json) {
    return FineAppeal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      fineId: json['fineId'] as String,
      reason: json['reason'] as String,
      additionalNotes: json['additionalNotes'] as String?,
      proofImageUrl: json['proofImageUrl'] as String?,
      proofDocumentUrl: json['proofDocumentUrl'] as String?,
      status: AppealStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppealStatus.pending,
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      resolvedBy: json['resolvedBy'] as String?,
      adminResponse: json['adminResponse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'fineId': fineId,
      'reason': reason,
      'additionalNotes': additionalNotes,
      'proofImageUrl': proofImageUrl,
      'proofDocumentUrl': proofDocumentUrl,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
      'adminResponse': adminResponse,
    };
  }

  FineAppeal copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? fineId,
    String? reason,
    String? additionalNotes,
    String? proofImageUrl,
    String? proofDocumentUrl,
    AppealStatus? status,
    DateTime? submittedAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? adminResponse,
  }) {
    return FineAppeal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      fineId: fineId ?? this.fineId,
      reason: reason ?? this.reason,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      proofDocumentUrl: proofDocumentUrl ?? this.proofDocumentUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }

  bool get canEdit => status == AppealStatus.pending;
  bool get canCancel => status == AppealStatus.pending;
  bool get isProcessed => 
      status == AppealStatus.approved ||
      status == AppealStatus.rejected ||
      status == AppealStatus.resolved ||
      status == AppealStatus.cancelled;
}
