import '../models/analytics_data.dart';

class AnalyticsService {
  // Mock data - replace with Firestore later
  Future<AnalyticsData> getAnalyticsData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    return AnalyticsData(
      peakOccupancy: 92.0,
      peakOccupancyTime: 'Today, 1:00 P.M.',
      popularBooksCount: 5,
      noShowRate: 7.8,
      lastWeekNoShowRate: 12.0,
      hourlyOccupancy: [
        HourlyOccupancy(hour: '8 AM', occupancy: 35),
        HourlyOccupancy(hour: '9 AM', occupancy: 48),
        HourlyOccupancy(hour: '10 AM', occupancy: 61),
        HourlyOccupancy(hour: '11 AM', occupancy: 75),
        HourlyOccupancy(hour: '12 PM', occupancy: 86),
        HourlyOccupancy(hour: '1 PM', occupancy: 92),
        HourlyOccupancy(hour: '2 PM', occupancy: 88),
        HourlyOccupancy(hour: '3 PM', occupancy: 70),
        HourlyOccupancy(hour: '4 PM', occupancy: 58),
        HourlyOccupancy(hour: '5 PM', occupancy: 45),
      ],
      popularBooks: [
        PopularBook(title: 'Clean Code', borrowCount: 42),
        PopularBook(title: 'Design Patterns', borrowCount: 37),
        PopularBook(title: 'Database Concepts', borrowCount: 28),
        PopularBook(title: 'Flutter Development', borrowCount: 24),
        PopularBook(title: 'Data Structures', borrowCount: 19),
      ],
    );
  }
}
