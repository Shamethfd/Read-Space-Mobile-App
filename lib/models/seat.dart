class Seat {
  final String id;
  final String seatNumber;
  final String row;
  final int position;
  final SeatStatus status;
  final bool hasPowerOutlet;
  final bool isNearWindow;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Seat({
    required this.id,
    required this.seatNumber,
    required this.row,
    required this.position,
    required this.status,
    this.hasPowerOutlet = false,
    this.isNearWindow = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as String,
      seatNumber: json['seatNumber'] as String,
      row: json['row'] as String,
      position: json['position'] as int,
      status: SeatStatus.fromString(json['status'] as String),
      hasPowerOutlet: json['hasPowerOutlet'] as bool? ?? false,
      isNearWindow: json['isNearWindow'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'row': row,
      'position': position,
      'status': status.value,
      'hasPowerOutlet': hasPowerOutlet,
      'isNearWindow': isNearWindow,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Seat copyWith({
    String? id,
    String? seatNumber,
    String? row,
    int? position,
    SeatStatus? status,
    bool? hasPowerOutlet,
    bool? isNearWindow,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Seat(
      id: id ?? this.id,
      seatNumber: seatNumber ?? this.seatNumber,
      row: row ?? this.row,
      position: position ?? this.position,
      status: status ?? this.status,
      hasPowerOutlet: hasPowerOutlet ?? this.hasPowerOutlet,
      isNearWindow: isNearWindow ?? this.isNearWindow,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum SeatStatus {
  available,
  occupied,
  damaged,
  maintenance,
  unavailable;

  String get value {
    switch (this) {
      case SeatStatus.available:
        return 'available';
      case SeatStatus.occupied:
        return 'occupied';
      case SeatStatus.damaged:
        return 'damaged';
      case SeatStatus.maintenance:
        return 'maintenance';
      case SeatStatus.unavailable:
        return 'unavailable';
    }
  }

  static SeatStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return SeatStatus.available;
      case 'occupied':
        return SeatStatus.occupied;
      case 'damaged':
        return SeatStatus.damaged;
      case 'maintenance':
        return SeatStatus.maintenance;
      case 'unavailable':
        return SeatStatus.unavailable;
      default:
        return SeatStatus.available;
    }
  }
}
