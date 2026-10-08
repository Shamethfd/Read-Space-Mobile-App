import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart' show AppTheme, AppRoutes;
import '../services/firestore_service.dart';
import '../models/booking.dart';
import '../models/hold.dart';
import '../models/book.dart';
import '../widgets/library_bottom_navigation.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  if (_currentUserId != null)
                    _SeatBookingsTab(userId: _currentUserId!)
                  else
                    const Center(child: Text('Please log in to view bookings')),
                  if (_currentUserId != null)
                    _BookHoldsTab(userId: _currentUserId!)
                  else
                    const Center(child: Text('Please log in to view holds')),
                ],
              ),
            ),
          ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'My Reservations',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF087BFA),
        unselectedLabelColor: const Color(0xFF8A929D),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: const Color(0xFF087BFA),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Seat Bookings'),
          Tab(text: 'Book Holds'),
        ],
      ),
    );
  }
}

class _SeatBookingsTab extends StatelessWidget {
  const _SeatBookingsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Booking>>(
      stream: firestoreService.getUserBookingsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: 'Unable to load reservations.',
            onRetry: () {},
          );
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return _EmptyState(
            icon: Icons.event_seat_outlined,
            title: 'No active seat reservations',
            subtitle: 'Book a seat to get started',
            actionLabel: 'Book a Seat',
            onAction: () => Navigator.pushNamed(context, AppRoutes.seatBooking),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SeatBookingCard(booking: booking),
            );
          },
        );
      },
    );
  }
}

class _BookHoldsTab extends StatelessWidget {
  const _BookHoldsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Hold>>(
      stream: firestoreService.getUserHoldsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(
            message: 'Unable to load book holds.',
            onRetry: () {},
          );
        }

        final holds = snapshot.data ?? [];

        if (holds.isEmpty) {
          return _EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No books on hold',
            subtitle: 'Browse the catalogue to place holds',
            actionLabel: 'Browse Catalog',
            onAction: () => Navigator.pushNamed(context, AppRoutes.catalogue),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: holds.length,
          itemBuilder: (context, index) {
            final hold = holds[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookHoldCard(hold: hold),
            );
          },
        );
      },
    );
  }
}

class _SeatBookingCard extends StatelessWidget {
  const _SeatBookingCard({required this.booking});

  final Booking booking;

  bool get _isActive {
    return booking.status == BookingStatus.confirmed &&
        DateTime.now().isBefore(booking.endTime);
  }

  bool get _isExpired {
    return DateTime.now().isAfter(booking.endTime);
  }

  String get _statusLabel {
    if (booking.status == BookingStatus.cancelled) return 'CANCELLED';
    if (booking.status == BookingStatus.completed) return 'COMPLETED';
    if (_isExpired) return 'EXPIRED';
    return 'ACTIVE';
  }

  Color get _statusColor {
    if (booking.status == BookingStatus.cancelled) return const Color(0xFF8A929D);
    if (booking.status == BookingStatus.completed) return const Color(0xFF16A34A);
    if (_isExpired) return const Color(0xFFFF3B30);
    return const Color(0xFF087BFA);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getRemainingTime() {
    if (!_isActive) return '0 mins';
    final remaining = booking.endTime.difference(DateTime.now());
    if (remaining.isNegative) return '0 mins';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes} mins';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_seat_rounded,
                  color: Color(0xFF087BFA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.seatId,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF20242A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Central Library • Floor 2',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8A929D),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF8A929D),
                ),
                const SizedBox(width: 6),
                Text(
                  'Reserved Slot',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8A929D),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF20242A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${_formatDate(booking.date)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF8A929D),
                ),
              ),
              const Spacer(),
              if (_isActive)
                Text(
                  '${_getRemainingTime()} left',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF087BFA),
                  ),
                ),
            ],
          ),
          if (_isActive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/manage-seat-reservation',
                    arguments: booking.id,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF087BFA),
                  side: const BorderSide(color: Color(0xFF087BFA)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookHoldCard extends StatefulWidget {
  const _BookHoldCard({required this.hold});

  final Hold hold;

  @override
  State<_BookHoldCard> createState() => _BookHoldCardState();
}

class _BookHoldCardState extends State<_BookHoldCard> {
  final FirestoreService _firestoreService = FirestoreService();
  Book? _book;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final book = await _firestoreService.getBookById(widget.hold.bookId);
      if (mounted) {
        setState(() => _book = book);
      }
    } catch (e) {
      // Keep book as null if fetch fails
    }
  }

  String get _statusLabel {
    switch (widget.hold.holdStatus) {
      case HoldStatus.pending:
        return 'ON HOLD';
      case HoldStatus.ready:
        return 'READY FOR PICKUP';
      case HoldStatus.expired:
        return 'EXPIRED';
      case HoldStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get _statusColor {
    switch (widget.hold.holdStatus) {
      case HoldStatus.pending:
        return const Color(0xFFF59E0B);
      case HoldStatus.ready:
        return const Color(0xFF16A34A);
      case HoldStatus.expired:
        return const Color(0xFFFF3B30);
      case HoldStatus.cancelled:
        return const Color(0xFF8A929D);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_book != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.bookDetail,
            arguments: _book!.id,
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 64,
              decoration: BoxDecoration(
                color: _book?.coverColor ?? const Color(0xFFE7F2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF087BFA),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _book?.title ?? 'Loading...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF20242A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _book?.author ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8A929D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(widget.hold.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF8A929D),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A929D),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F2FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF087BFA)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF20242A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF8A929D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087BFA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFFF3B30),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF8A929D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
