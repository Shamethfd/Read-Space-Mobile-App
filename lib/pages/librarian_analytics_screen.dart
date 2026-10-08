import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart' show AppTheme, AppRoutes;
import '../services/analytics_service.dart';
import '../models/analytics_data.dart';
import '../widgets/analytics_metric_card.dart';
import '../widgets/popular_book_item.dart';

class LibrarianAnalyticsScreen extends StatefulWidget {
  const LibrarianAnalyticsScreen({super.key});

  @override
  State<LibrarianAnalyticsScreen> createState() => _LibrarianAnalyticsScreenState();
}

class _LibrarianAnalyticsScreenState extends State<LibrarianAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  late Future<AnalyticsData> _analyticsData;

  @override
  void initState() {
    super.initState();
    _analyticsData = _analyticsService.getAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateFilter(),
              const SizedBox(height: 16),
              _buildMetricCards(),
              const SizedBox(height: 16),
              _buildHourlyOccupancyChart(),
              const SizedBox(height: 16),
              _buildPopularBooks(),
              const SizedBox(height: 16),
              _buildExportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            'Apr 28, 2026 – May 4, 2026',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, color: AppTheme.secondaryText, size: 20),
        ],
      ),
    );
  }

  Widget _buildMetricCards() {
    return FutureBuilder<AnalyticsData>(
      future: _analyticsData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load analytics'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AnalyticsMetricCard(
                    title: 'Peak Occupancy',
                    subtitle: data.peakOccupancyTime,
                    value: '${data.peakOccupancy.toInt()}%',
                    icon: Icons.trending_up,
                    valueColor: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnalyticsMetricCard(
                    title: 'Popular Books',
                    subtitle: 'Top 5 this week',
                    value: data.popularBooksCount.toString(),
                    icon: Icons.menu_book,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnalyticsMetricCard(
                    title: 'No-show rate',
                    subtitle: 'vs. ${data.lastWeekNoShowRate.toInt()}% last week',
                    value: '${data.noShowRate}%',
                    icon: Icons.person_off,
                    valueColor: data.noShowRate < data.lastWeekNoShowRate
                        ? AppTheme.success
                        : AppTheme.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnalyticsMetricCard(
                    title: 'Export Report',
                    subtitle: 'Download analytics',
                    value: 'PDF',
                    icon: Icons.download,
                    valueColor: AppTheme.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHourlyOccupancyChart() {
    return FutureBuilder<AnalyticsData>(
      future: _analyticsData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room Occupancy (Hourly)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    minY: 0,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.hourlyOccupancy.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                data.hourlyOccupancy[index].hour,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: data.hourlyOccupancy.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.occupancy.toDouble(),
                            color: AppTheme.primaryBlue,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularBooks() {
    return FutureBuilder<AnalyticsData>(
      future: _analyticsData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final maxCount = data.popularBooks
            .map((b) => b.borrowCount)
            .reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Books',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...data.popularBooks.map((book) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PopularBookItem(book: book, maxCount: maxCount),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement export functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export feature coming soon')),
          );
        },
        icon: const Icon(Icons.download),
        label: Text(
          'Export Report',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
