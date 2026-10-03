enum NoticePriority {
  normal,
  important,
  urgent,
}

enum NoticeCategory {
  general,
  important,
  library,
  events,
  maintenance,
  academic,
}

enum NoticeStatus {
  draft,
  published,
  expired,
}

class Notice {
  final String id;
  final String title;
  final String description;
  final NoticeCategory category;
  final NoticePriority priority;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final DateTime? expiryDate;
  final DateTime? eventDate;
  final String createdBy;
  final NoticeStatus status;
  final String? attachmentUrl;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.publishedAt,
    required this.updatedAt,
    this.expiryDate,
    this.eventDate,
    required this.createdBy,
    required this.status,
    this.attachmentUrl,
  });

  // Check if notice is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if notice is currently active (published and not expired)
  bool get isActive => status == NoticeStatus.published && !isExpired;

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: NoticeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NoticeCategory.general,
      ),
      priority: NoticePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NoticePriority.normal,
      ),
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      status: NoticeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NoticeStatus.draft,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'eventDate': eventDate?.toIso8601String(),
      'createdBy': createdBy,
      'status': status.name,
      'attachmentUrl': attachmentUrl,
    };
  }

  Notice copyWith({
    String? id,
    String? title,
    String? description,
    NoticeCategory? category,
    NoticePriority? priority,
    DateTime? publishedAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    DateTime? eventDate,
    String? createdBy,
    NoticeStatus? status,
    String? attachmentUrl,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      eventDate: eventDate ?? this.eventDate,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
