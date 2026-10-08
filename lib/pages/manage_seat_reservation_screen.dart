import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppTheme, AppRoutes;
import '../services/firestore_service.dart';
import '../models/booking.dart';
import '../widgets/library_bottom_navigation.dart';

class ManageSeatReservationScreen extends StatefulWidget {
  const ManageSeatReservationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ManageSeatReservationScreen> createState() =>
      _ManageSeatReservationScreenState();
}

class _ManageSeatReservationScreenState
    extends State<ManageSeatReservationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Booking? _booking;
  bool _isLoading = true;
  bool _isExtending = false;
  bool _isCancelling = false;
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    try {
      final booking = await _firestoreService.getBookingById(widget.bookingId);
      if (mounted) {
        setState(() {
          _booking = booking;
          _isLoading = false;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load booking: $e')),
        );
      }
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  bool get _isActive {
    if (_booking == null) return false;
    return _booking!.status == BookingStatus.confirmed &&
        DateTime.now().isBefore(_booking!.endTime);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getRemainingTime() {
    if (_booking == null || !_isActive) return '0 mins';
    final remaining = _booking!.endTime.difference(DateTime.now());
    if (remaining.isNegative) return '0 mins';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes} mins';
  }

  String _getStatusLabel() {
    if (_booking == null) return 'UNKNOWN';
    if (_booking!.status == BookingStatus.cancelled) return 'CANCELLED';
    if (_booking!.status == BookingStatus.completed) return 'COMPLETED';
    if (!_isActive) return 'EXPIRED';
    return 'ACTIVE';
  }

  Color _getStatusColor() {
    if (_booking == null) return AppTheme.secondaryText;
    if (_booking!.status == BookingStatus.cancelled) return AppTheme.secondaryText;
    if (_booking!.status == BookingStatus.completed) return AppTheme.success;
    if (!_isActive) return AppTheme.red;
    return const Color(0xFF087BFA);
  }

  Future<void> _extendBooking(int minutes) async {
    if (_booking == null || !_isActive) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Extension?'),
        content: Text('Extend your reservation by $minutes minutes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF087BFA)),
            child: const Text('Confirm Extension'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isExtending = true);

    try {
      final newEndTime = _booking!.endTime.add(Duration(minutes: minutes));
      await _firestoreService.extendBooking(_booking!.id, newEndTime);

      if (mounted) {
        setState(() => _isExtending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking extended successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadBooking();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to extend booking: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    if (_booking == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: const Text(
            'Are you sure you want to cancel this seat reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Reservation'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Cancel Reservation'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      await _firestoreService.cancelBooking(_booking!.id);

      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation cancelled successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadBooking();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel reservation: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_booking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: const Center(child: Text('Booking not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingCard(),
              const SizedBox(height: 20),
              if (_isActive) ...[
                _buildExtendSection(),
                const SizedBox(height: 20),
              ],
              if (_isActive)
                _buildCancelButton()
              else
                _buildStatusCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: LibraryBottomNavigation(
        selectedIndex: 2,
        onSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.catalogue);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF20242A),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        'Manage Reservation',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF20242A),
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_seat_rounded,
                  color: Color(0xFF087BFA),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _booking!.seatId,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF20242A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Central Library • Floor 2',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF8A929D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Date', _formatDate(_booking!.date),
              Icons.calendar_today_outlined),
          const SizedBox(height: 12),
          _buildDetailRow('Time Slot',
              '${_formatTime(_booking!.startTime)} - ${_formatTime(_booking!.endTime)}',
              Icons.access_time_outlined),
          const SizedBox(height: 12),
          _buildDetailRow('Remaining Time', _getRemainingTime(),
              Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8A929D)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8A929D),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF20242A),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildExtendSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extend Time',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF20242A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add more time to your current reservation',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF8A929D),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ExtensionOption(
                  label: '+30 Mins',
                  minutes: 30,
                  onSelected: _isExtending ? null : _extendBooking,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExtensionOption(
                  label: '+1 Hour',
                  minutes: 60,
                  onSelected: _isExtending ? null : _extendBooking,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExtensionOption(
                  label: '+2 Hours',
                  minutes: 120,
                  onSelected: _isExtending ? null : _extendBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _cancelBooking,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.red,
          side: const BorderSide(color: AppTheme.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isCancelling
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppTheme.red, strokeWidth: 2),
              )
            : Text(
                'Cancel Reservation',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFDC2626), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This reservation has been ${_getStatusLabel().toLowerCase()}. You cannot manage expired or cancelled reservations.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtensionOption extends StatelessWidget {
  const _ExtensionOption({
    required this.label,
    required this.minutes,
    required this.onSelected,
  });

  final String label;
  final int minutes;
  final void Function(int)? onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected != null ? () => onSelected!(minutes) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onSelected != null
              ? const Color(0xFFE7F2FF)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onSelected != null
                ? const Color(0xFF087BFA)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onSelected != null
                ? const Color(0xFF087BFA)
                : const Color(0xFF8A929D),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
