class AnalyticsData {
  final double peakOccupancy;
  final String peakOccupancyTime;
  final int popularBooksCount;
  final double noShowRate;
  final double lastWeekNoShowRate;
  final List<HourlyOccupancy> hourlyOccupancy;
  final List<PopularBook> popularBooks;

  AnalyticsData({
    required this.peakOccupancy,
    required this.peakOccupancyTime,
    required this.popularBooksCount,
    required this.noShowRate,
    required this.lastWeekNoShowRate,
    required this.hourlyOccupancy,
    required this.popularBooks,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      peakOccupancy: (json['peakOccupancy'] as num).toDouble(),
      peakOccupancyTime: json['peakOccupancyTime'] as String,
      popularBooksCount: json['popularBooksCount'] as int,
      noShowRate: (json['noShowRate'] as num).toDouble(),
      lastWeekNoShowRate: (json['lastWeekNoShowRate'] as num).toDouble(),
      hourlyOccupancy: (json['hourlyOccupancy'] as List)
          .map((e) => HourlyOccupancy.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularBooks: (json['popularBooks'] as List)
          .map((e) => PopularBook.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peakOccupancy': peakOccupancy,
      'peakOccupancyTime': peakOccupancyTime,
      'popularBooksCount': popularBooksCount,
      'noShowRate': noShowRate,
      'lastWeekNoShowRate': lastWeekNoShowRate,
      'hourlyOccupancy': hourlyOccupancy.map((e) => e.toJson()).toList(),
      'popularBooks': popularBooks.map((e) => e.toJson()).toList(),
    };
  }
}

class HourlyOccupancy {
  final String hour;
  final int occupancy;

  HourlyOccupancy({required this.hour, required this.occupancy});

  factory HourlyOccupancy.fromJson(Map<String, dynamic> json) {
    return HourlyOccupancy(
      hour: json['hour'] as String,
      occupancy: json['occupancy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'occupancy': occupancy,
    };
  }
}

class PopularBook {
  final String title;
  final int borrowCount;

  PopularBook({required this.title, required this.borrowCount});

  factory PopularBook.fromJson(Map<String, dynamic> json) {
    return PopularBook(
      title: json['title'] as String,
      borrowCount: json['borrowCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'borrowCount': borrowCount,
    };
  }
}
