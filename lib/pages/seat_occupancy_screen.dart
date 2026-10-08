import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppTheme, AppRoutes;
import '../services/firestore_service.dart';
import '../models/seat.dart';
import '../models/booking.dart';
import '../widgets/resource_allocation_card.dart';

class SeatOccupancyScreen extends StatefulWidget {
  const SeatOccupancyScreen({super.key});

  @override
  State<SeatOccupancyScreen> createState() => _SeatOccupancyScreenState();
}

class _SeatOccupancyScreenState extends State<SeatOccupancyScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFloor = '2nd Floor';

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
          'Seat Occupancy',
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
              _buildFloorSelector(),
              const SizedBox(height: 16),
              _buildStatusLegend(),
              const SizedBox(height: 16),
              _buildSeatMap(),
              const SizedBox(height: 16),
              _buildResourceAllocation(),
              const SizedBox(height: 16),
              _buildUsagePattern(),
              const SizedBox(height: 16),
              _buildExportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.layers, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            _selectedFloor,
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

  Widget _buildStatusLegend() {
    return Row(
      children: [
        _buildLegendItem('Available', AppTheme.success),
        const SizedBox(width: 16),
        _buildLegendItem('Occupied', AppTheme.primaryBlue),
        const SizedBox(width: 16),
        _buildLegendItem('Unavailable', AppTheme.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    return StreamBuilder<List<Seat>>(
      stream: _firestoreService.getSeatsStream(),
      builder: (context, seatsSnapshot) {
        return StreamBuilder<List<Booking>>(
          stream: _firestoreService.getAllBookingsStream(),
          builder: (context, bookingsSnapshot) {
            if (seatsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (seatsSnapshot.hasError) {
              return const Center(child: Text('Failed to load seats'));
            }

            final seats = seatsSnapshot.data ?? [];
            final bookings = bookingsSnapshot.data ?? [];

            if (seats.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Center(
                  child: Text('No seats available'),
                ),
              );
            }

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
                    'Seat Map',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSeatGrid(seats, bookings),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSeatGrid(List<Seat> seats, List<Booking> bookings) {
    final now = DateTime.now();
    final Map<String, SeatStatus> seatStatuses = {};

    for (final seat in seats) {
      if (seat.status == SeatStatus.damaged ||
          seat.status == SeatStatus.maintenance ||
          seat.status == SeatStatus.unavailable) {
        seatStatuses[seat.seatNumber] = seat.status;
      } else {
        final hasActiveBooking = bookings.any((b) =>
            b.seatId == seat.seatNumber &&
            b.status == BookingStatus.confirmed &&
            b.startTime.isBefore(now) &&
            b.endTime.isAfter(now));
        seatStatuses[seat.seatNumber] =
            hasActiveBooking ? SeatStatus.occupied : SeatStatus.available;
      }
    }

    final rows = <List<Seat>>[];
    final rowMap = <String, List<Seat>>{};
    for (final seat in seats) {
      if (!rowMap.containsKey(seat.row)) {
        rowMap[seat.row] = [];
      }
      rowMap[seat.row]!.add(seat);
    }

    final sortedRows = rowMap.keys.toList()..sort();
    for (final row in sortedRows) {
      final rowSeats = rowMap[row]!..sort((a, b) => a.position.compareTo(b.position));
      rows.add(rowSeats);
    }

    return Column(
      children: rows.map((rowSeats) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                rowSeats.first.row,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: rowSeats.map((seat) {
                    final status = seatStatuses[seat.seatNumber] ?? SeatStatus.available;
                    return _buildSeatTile(seat, status, bookings);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatTile(Seat seat, SeatStatus status, List<Booking> bookings) {
    Color color;
    switch (status) {
      case SeatStatus.available:
        color = AppTheme.success;
        break;
      case SeatStatus.occupied:
        color = AppTheme.primaryBlue;
        break;
      case SeatStatus.damaged:
      case SeatStatus.maintenance:
      case SeatStatus.unavailable:
        color = AppTheme.red;
        break;
    }

    return GestureDetector(
      onTap: () => _showSeatDetails(seat, status, bookings),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seat.position.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _showSeatDetails(Seat seat, SeatStatus status, List<Booking> bookings) {
    final now = DateTime.now();
    final activeBooking = bookings.firstWhere(
      (b) =>
          b.seatId == seat.seatNumber &&
          b.status == BookingStatus.confirmed &&
          b.startTime.isBefore(now) &&
          b.endTime.isAfter(now),
      orElse: () => bookings.first,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Seat ${seat.seatNumber}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Floor', _selectedFloor),
            _buildDetailRow('Status', status.value),
            if (status == SeatStatus.occupied) ...[
              _buildDetailRow('Current User', activeBooking.userName ?? 'Unknown'),
              _buildDetailRow('Booking Time', _formatTime(activeBooking.startTime)),
              _buildDetailRow('Expected Release', _formatTime(activeBooking.endTime)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildResourceAllocation() {
    return StreamBuilder<List<Seat>>(
      stream: _firestoreService.getSeatsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final seats = snapshot.data!;
        final occupied = seats.where((s) => s.status == SeatStatus.occupied).length;
        final available = seats.where((s) => s.status == SeatStatus.available).length;
        final unavailable = seats.where((s) =>
            s.status == SeatStatus.damaged ||
            s.status == SeatStatus.maintenance ||
            s.status == SeatStatus.unavailable).length;

        return ResourceAllocationCard(
          occupied: occupied,
          available: available,
          reserved: 0,
          unavailable: unavailable,
        );
      },
    );
  }

  Widget _buildUsagePattern() {
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
            'Usage Pattern',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPatternRow('Most used', '2nd Floor (88%)'),
          const SizedBox(height: 12),
          _buildPatternRow('Peak hours', '10:00 AM – 2:00 PM'),
        ],
      ),
    );
  }

  Widget _buildPatternRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
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
