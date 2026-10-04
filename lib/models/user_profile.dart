class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String studentId;
  final String facultyDepartment;
  final String universityEmail;
  final double outstandingFines;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.studentId = '',
    this.facultyDepartment = '',
    this.universityEmail = '',
    this.outstandingFines = 0,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      facultyDepartment: json['facultyDepartment'] as String? ?? '',
      universityEmail: json['universityEmail'] as String? ?? '',
      outstandingFines: (json['outstandingFines'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
      'facultyDepartment': facultyDepartment,
      'universityEmail': universityEmail,
      'outstandingFines': outstandingFines,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? studentId,
    String? facultyDepartment,
    String? universityEmail,
    double? outstandingFines,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentId: studentId ?? this.studentId,
      facultyDepartment: facultyDepartment ?? this.facultyDepartment,
      universityEmail: universityEmail ?? this.universityEmail,
      outstandingFines: outstandingFines ?? this.outstandingFines,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
