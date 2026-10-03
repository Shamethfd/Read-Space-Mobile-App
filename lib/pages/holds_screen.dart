import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/models/hold.dart';

class HoldsScreen extends StatefulWidget {
  const HoldsScreen({super.key});

  @override
  State<HoldsScreen> createState() => _HoldsScreenState();
}

class _HoldsScreenState extends State<HoldsScreen> {
  static List<Book> get _sampleBooks => [
    Book(
      id: '1',
      title: 'Design Patterns',
      author: 'E. Gamma, R. Helm, R. Johnson',
      isbn: '9780201633610',
      genre: 'Technology',
      description: 'Elements of Reusable Object-Oriented Software',
      pages: 395,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.general,
      shelfLocation: 'A-12',
      totalCopies: 3,
      availableCopies: 2,
      holdCount: 1,
      coverColor: const Color(0xFF123C69),
    ),
    Book(
      id: '2',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      genre: 'Technology',
      description: 'A Handbook of Agile Software Craftsmanship',
      pages: 464,
      language: 'English',
      status: BookStatus.onLoan,
      section: LibrarySection.quiet,
      shelfLocation: 'Q-05',
      totalCopies: 2,
      availableCopies: 0,
      holdCount: 3,
      coverColor: const Color(0xFFE8A43A),
    ),
  ];

  static List<Hold> get _sampleHolds => [
    Hold(
      id: 'h1',
      bookId: '2',
      userId: 'user1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      holdStatus: HoldStatus.pending,
      queuePosition: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final holds = _sampleHolds;
    final books = _sampleBooks;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.pageBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        leading: BackButton(color: AppTheme.textPrimary),
        title: const Text('My Holds'),
        centerTitle: true,
      ),
      body: holds.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded,
                      size: 64, color: AppTheme.secondaryText),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Holds',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any books on hold.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: holds.length,
              itemBuilder: (context, index) {
                final hold = holds[index];
                final book = books.firstWhere(
                  (b) => b.id == hold.bookId,
                  orElse: () => books[0],
                );
                return _HoldCard(hold: hold, book: book);
              },
            ),
    );
  }
}

class _HoldCard extends StatelessWidget {
  const _HoldCard({required this.hold, required this.book});
  final Hold hold;
  final Book book;

  @override
  Widget build(BuildContext context) {
    final statusColor;
    switch (hold.holdStatus) {
      case HoldStatus.pending:
        statusColor = AppTheme.orange;
        break;
      case HoldStatus.ready:
        statusColor = AppTheme.success;
        break;
      case HoldStatus.expired:
        statusColor = AppTheme.red;
        break;
      case HoldStatus.cancelled:
        statusColor = AppTheme.secondaryText;
        break;
    }

    final statusLabel;
    switch (hold.holdStatus) {
      case HoldStatus.pending:
        statusLabel = 'In Queue';
        break;
      case HoldStatus.ready:
        statusLabel = 'Ready for Pickup';
        break;
      case HoldStatus.expired:
        statusLabel = 'Expired';
        break;
      case HoldStatus.cancelled:
        statusLabel = 'Cancelled';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 68,
              decoration: BoxDecoration(
                color: book.coverColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: Colors.white38, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hold.holdStatus == HoldStatus.pending)
                        Text(
                          'Position #${hold.queuePosition}',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.secondaryText),
                        ),
                    ],
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
