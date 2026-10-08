import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes;
import 'package:read_space/services/firestore_service.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/models/seat.dart';
import 'package:read_space/models/booking.dart';

class LibrarianInventoryScreen extends StatefulWidget {
  const LibrarianInventoryScreen({super.key});

  @override
  State<LibrarianInventoryScreen> createState() => _LibrarianInventoryScreenState();
}

class _LibrarianInventoryScreenState extends State<LibrarianInventoryScreen> {
  int _currentIndex = 1;
  int _selectedTab = 0; // 0 = Books, 1 = Desks
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 16),
                    if (_selectedTab == 0) _buildBooksTab() else _buildDesksTab(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inventory & Desks',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Icon(
            Icons.more_vert,
            color: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppTheme.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search books, author, rack or desk...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
          Icon(
            Icons.filter_list,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Books',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 0 ? AppTheme.primaryBlue : AppTheme.secondaryText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Desks',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 1 ? AppTheme.primaryBlue : AppTheme.secondaryText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Book Inventory',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            StreamBuilder<List<Book>>(
              stream: _firestoreService.getBooksStream(),
              builder: (context, snapshot) {
                final bookCount = snapshot.data?.length ?? 0;
                return Text(
                  'Total: $bookCount',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryText,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Book>>(
          stream: _firestoreService.getBooksStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data ?? [];

            if (books.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 48,
                        color: AppTheme.secondaryText,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No books in inventory',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: books.map((book) => _buildBookCard(book)).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.librarianAddBook),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Book',
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
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: book.coverColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.menu_book,
              color: book.coverColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ISBN: ${book.isbn}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: book.availableCopies > 0
                  ? AppTheme.success.withValues(alpha: 0.1)
                  : AppTheme.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              book.availableCopies > 0 ? 'Available' : 'Unavailable',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: book.availableCopies > 0 ? AppTheme.success : AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesksTab() {
    return StreamBuilder<List<Seat>>(
      stream: _firestoreService.getSeatsStream(),
      builder: (context, seatsSnapshot) {
        return StreamBuilder<List<Booking>>(
          stream: _firestoreService.getAllBookingsStream(),
          builder: (context, bookingsSnapshot) {
            final seats = seatsSnapshot.data ?? [];
            final bookings = bookingsSnapshot.data ?? [];

            if (seatsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (seatsSnapshot.hasError) {
              return _buildErrorState(seatsSnapshot.error.toString());
            }

            if (seats.isEmpty) {
              return _buildEmptyState();
            }

            return _buildSeatManagementContent(seats, bookings);
          },
        );
      },
    );
  }

  Widget _buildSeatManagementContent(List<Seat> seats, List<Booking> bookings) {
    final totalDesks = seats.length;
    final availableCount = seats.where((s) => s.status == SeatStatus.available).length;
    final occupiedCount = seats.where((s) => s.status == SeatStatus.occupied).length;
    final unavailableCount = seats.where((s) => 
      s.status == SeatStatus.damaged || 
      s.status == SeatStatus.maintenance || 
      s.status == SeatStatus.unavailable
    ).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Desk / Seat Management',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Total Desks: $totalDesks',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatusSummary(availableCount, occupiedCount, unavailableCount),
        const SizedBox(height: 16),
        _buildSeatList(seats, bookings),
      ],
    );
  }

  Widget _buildStatusSummary(int available, int occupied, int unavailable) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusCount('Available', available, AppTheme.success),
          _buildStatusCount('Occupied', occupied, AppTheme.red),
          _buildStatusCount('Unavailable', unavailable, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatList(List<Seat> seats, List<Booking> bookings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildSeatListHeader(),
          const Divider(height: 1, color: AppTheme.border),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
            itemBuilder: (context, index) {
              final seat = seats[index];
              final currentStatus = _getSeatStatus(seat, bookings);
              return _buildSeatRow(seat, currentStatus, bookings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeatListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8F9FA),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Seat No.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Damaged/Unavailable',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRow(Seat seat, SeatStatus currentStatus, List<Booking> bookings) {
    final isUnavailable = seat.status == SeatStatus.damaged || 
                          seat.status == SeatStatus.maintenance || 
                          seat.status == SeatStatus.unavailable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              seat.seatNumber,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(currentStatus),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Switch(
                value: isUnavailable,
                onChanged: (value) {
                  _toggleSeatStatus(seat, value);
                },
                activeColor: AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SeatStatus status) {
    Color color;
    String label;

    switch (status) {
      case SeatStatus.available:
        color = AppTheme.success;
        label = 'Available';
        break;
      case SeatStatus.occupied:
        color = AppTheme.red;
        label = 'Occupied';
        break;
      case SeatStatus.damaged:
        color = AppTheme.red;
        label = 'Damaged';
        break;
      case SeatStatus.maintenance:
        color = const Color(0xFFF59E0B);
        label = 'Maintenance';
        break;
      case SeatStatus.unavailable:
        color = const Color(0xFF8A929D);
        label = 'Unavailable';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  SeatStatus _getSeatStatus(Seat seat, List<Booking> bookings) {
    // If seat is marked as damaged/maintenance/unavailable, return that status
    if (seat.status == SeatStatus.damaged) return SeatStatus.damaged;
    if (seat.status == SeatStatus.maintenance) return SeatStatus.maintenance;
    if (seat.status == SeatStatus.unavailable) return SeatStatus.unavailable;

    // Check if seat has an active booking
    final now = DateTime.now();
    final activeBooking = bookings.any((b) => 
      b.seatId == seat.seatNumber &&
      b.status == BookingStatus.confirmed &&
      b.startTime.isBefore(now) &&
      b.endTime.isAfter(now)
    );

    return activeBooking ? SeatStatus.occupied : SeatStatus.available;
  }

  Future<void> _toggleSeatStatus(Seat seat, bool isUnavailable) async {
    try {
      final newStatus = isUnavailable ? SeatStatus.damaged : SeatStatus.available;
      await _firestoreService.updateSeatStatus(seat.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seat ${seat.seatNumber} status updated'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update seat status: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading desks...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.red),
            const SizedBox(height: 12),
            Text(
              'Unable to load desk information.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_seat_outlined,
              size: 48,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              'No desks have been configured yet.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeDefaultSeats,
              icon: const Icon(Icons.add),
              label: Text(
                'Initialize Default Seats',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeDefaultSeats() async {
    try {
      await _firestoreService.initializeDefaultSeats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default seats initialized successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize seats: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.bar_chart_outlined,
            label: 'Analytics',
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.person_outlined,
            label: 'Profile',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.librarianDashboard);
        } else if (index == 3) {
          Navigator.pushNamed(context, AppRoutes.librarianProfile);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryBlue : AppTheme.secondaryText,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primaryBlue : AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
