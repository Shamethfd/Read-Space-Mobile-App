import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart' show AppRoutes;
import '../widgets/library_bottom_navigation.dart';
import '../widgets/notification_badge.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';
import '../models/hold.dart';
import 'member_profile_page.dart';
import 'seat_booking_flow.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNavigationIndex = 0;
  final _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashboardColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardHeader(userId: _currentUserId),
              const SizedBox(height: 22),
              const _BookingAlert(),
              const SizedBox(height: 18),
              _SearchBar(controller: _searchController),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.search_rounded,
                      title: 'Search Catalogue',
                      subtitle: 'Browse library',
                      color: _DashboardColors.primary,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.catalogue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.event_seat_rounded,
                      title: 'Book a Seat',
                      subtitle: 'Reserve study desks',
                      color: _DashboardColors.orange,
                      onTap: _openSeatBooking,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bookmark_rounded,
                      title: 'My Reservations',
                      subtitle: 'View bookings & holds',
                      color: const Color(0xFF16A34A),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.myReservations),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.notifications_rounded,
                      title: 'Notices',
                      subtitle: 'Library updates',
                      color: const Color(0xFF8B5CF6),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'Recent Reservations',
                action: 'See All',
                onAction: () =>
                    Navigator.pushNamed(context, AppRoutes.myReservations),
              ),
              const SizedBox(height: 12),
              if (_currentUserId != null)
                _RecentHolds(userId: _currentUserId!)
              else
                const Center(child: Text('Log in to view reservations')),
              const SizedBox(height: 28),
              const _SectionHeader(title: 'Trending Books', action: 'View All'),
              const SizedBox(height: 12),
              _TrendingBooks(firestoreService: _firestoreService),
            ],
          ),
        ),
      ),
      bottomNavigationBar: LibraryBottomNavigation(
        selectedIndex: _selectedNavigationIndex,
        onSelected: _handleNavigation,
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.catalogue);
      return;
    }
    if (index == 2) {
      _openSeatBooking();
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(
        context,
        AppRoutes.profile,
        arguments: const MemberProfileData(
          fullName: 'Fernando K S R',
          memberId: 'IT23624344',
          phoneNumber: '+94 71 234 5678',
          universityEmail: 'fernando@uni.ac.lk',
          facultyDepartment: 'Faculty of Computing',
          outstandingFines: 150.00,
          borrowingHistory: [
            BorrowedBook(
              title: 'Design Patterns',
              author: 'E. Gamma, R. Helm, R. Johnson',
              status: BorrowingStatus.active,
              dateLabel: 'Today, 05:00 PM',
            ),
            BorrowedBook(
              title: 'Data Structures & Algorithms',
              author: 'Michael T. Goodrich',
              status: BorrowingStatus.overdue,
              dateLabel: '15 Oct 2025',
            ),
            BorrowedBook(
              title: 'Clean Code',
              author: 'Robert C. Martin',
              status: BorrowingStatus.returned,
              dateLabel: 'Returned: 08 Oct 2025',
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _selectedNavigationIndex = index);
  }

  void _openSeatBooking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SeatBookingFlow(),
        settings: const RouteSettings(name: AppRoutes.seatBooking),
      ),
    );
  }
}

class _DashboardColors {
  static const primary = Color(0xFF0B8FF5);
  static const secondary = Color(0xFF2563EB);
  static const orange = Color(0xFFF59E0B);
  static const background = Color(0xFFF8FAFC);
  static const text = Color(0xFF172033);
  static const muted = Color(0xFF718096);
  static const border = Color(0xFFE8EDF3);
  static const green = Color(0xFF18A66A);
  static const red = Color(0xFFD95D5D);
}

class _DashboardHeader extends StatefulWidget {
  const _DashboardHeader({this.userId});

  final String? userId;

  @override
  State<_DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<_DashboardHeader> {
  final _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (widget.userId == null) return;
    final count = await _notificationService.getUnreadCount(widget.userId!);
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _DashboardColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'READSPACE',
              style: GoogleFonts.poppins(
                color: _DashboardColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _DashboardColors.muted,
                ),
                children: [
                  const TextSpan(text: 'Hello, '),
                  TextSpan(
                    text: widget.userId != null ? 'Student!' : 'Guest',
                    style: GoogleFonts.poppins(
                      color: _DashboardColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        NotificationBadge(
          count: _unreadCount,
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: _DashboardColors.text,
            ),
          ),
        ),
        const SizedBox(width: 2),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFFD9E8F5),
          child: Icon(
            Icons.person_rounded,
            color: _DashboardColors.secondary,
            size: 23,
          ),
        ),
      ],
    );
  }
}

class _BookingAlert extends StatelessWidget {
  const _BookingAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5D9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFE6A8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFE99B13),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your booking at Study Room 3B starts in 15 mins.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF855D11),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 12.5, color: _DashboardColors.text),
      decoration: InputDecoration(
        hintText: 'Search books, authors, seats...',
        hintStyle: GoogleFonts.poppins(
          fontSize: 12.5,
          color: _DashboardColors.muted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _DashboardColors.muted,
          size: 21,
        ),
        suffixIcon: IconButton(
          onPressed: () {},
          tooltip: 'Filter search',
          icon: const Icon(
            Icons.tune_rounded,
            color: _DashboardColors.muted,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _DashboardColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _DashboardColors.primary,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, this.onAction});

  final String title;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: _DashboardColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction ?? () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: GoogleFonts.poppins(
              color: _DashboardColors.primary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentReservationCard extends StatelessWidget {
  const _RecentReservationCard({
    required this.category,
    required this.status,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.statusColor,
    this.onTap,
  });

  final String category;
  final String status;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _DashboardColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _DashboardColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: _DashboardColors.muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(label: status, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: _DashboardColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: _DashboardColors.muted,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: _DashboardColors.text,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingBookCard extends StatelessWidget {
  const _TrendingBookCard({
    required this.title,
    required this.author,
    required this.status,
    required this.statusColor,
    required this.coverColor,
    required this.coverIcon,
  });

  final String title;
  final String author;
  final String status;
  final Color statusColor;
  final Color coverColor;
  final IconData coverIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DashboardColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 70,
            decoration: BoxDecoration(
              color: coverColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              coverIcon,
              color: Colors.white.withValues(alpha: .85),
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _DashboardColors.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _DashboardColors.muted,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 8),
                _StatusPill(label: status, color: statusColor),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: _DashboardColors.muted,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecentHolds extends StatelessWidget {
  const _RecentHolds({required this.userId});

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
          return const Center(child: Text('Error loading holds'));
        }

        final holds = snapshot.data ?? [];

        if (holds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No active holds'),
          );
        }

        final recentHolds = holds.take(2).toList();

        return Column(
          children: recentHolds.map((hold) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecentReservationCard(
                category: 'BOOK HOLD',
                status: hold.holdStatus.name.toUpperCase(),
                title: 'Book #${hold.bookId}',
                subtitle: 'Queue position: ${hold.queuePosition}',
                time: 'Created: ${_formatDate(hold.createdAt)}',
                icon: Icons.menu_book_outlined,
                statusColor: _getStatusColor(hold.holdStatus),
                onTap: () => Navigator.pushNamed(context, AppRoutes.holds),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(HoldStatus status) {
    switch (status) {
      case HoldStatus.pending:
        return _DashboardColors.orange;
      case HoldStatus.ready:
        return _DashboardColors.green;
      case HoldStatus.expired:
        return _DashboardColors.red;
      case HoldStatus.cancelled:
        return _DashboardColors.muted;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TrendingBooks extends StatelessWidget {
  const _TrendingBooks({required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: firestoreService.getBooksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading books'));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No books available'),
          );
        }

        final trendingBooks = books.take(2).toList();

        return Column(
          children: trendingBooks.map((book) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TrendingBookCard(
                title: book.title,
                author: '${book.author}  •  ${book.genre}',
                status: book.availableCopies > 0 ? 'Available' : 'On Loan',
                statusColor: book.availableCopies > 0
                    ? _DashboardColors.green
                    : _DashboardColors.red,
                coverColor: book.coverColor,
                coverIcon: Icons.menu_book,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
