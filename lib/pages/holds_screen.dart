import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/models/hold.dart';
import 'package:read_space/services/firestore_service.dart';

class HoldsScreen extends StatefulWidget {
  const HoldsScreen({super.key});

  @override
  State<HoldsScreen> createState() => _HoldsScreenState();
}

class _HoldsScreenState extends State<HoldsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
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
        body: const Center(
          child: Text('Please log in to view your holds'),
        ),
      );
    }

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
      body: StreamBuilder<List<Hold>>(
        stream: _firestoreService.getUserHoldsStream(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.secondaryText),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load holds',
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            );
          }

          final holds = snapshot.data ?? [];

          if (holds.isEmpty) {
            return Center(
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
            );
          }

          return FutureBuilder<List<Book>>(
            future: _loadBooksForHolds(holds),
            builder: (context, booksSnapshot) {
              if (booksSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (booksSnapshot.hasError) {
                return Center(
                  child: Text('Error loading books'),
                );
              }

              final books = booksSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: holds.length,
                itemBuilder: (context, index) {
                  final hold = holds[index];
                  final book = books.firstWhere(
                    (b) => b.id == hold.bookId,
                    orElse: () => _createPlaceholderBook(),
                  );
                  return _HoldCard(hold: hold, book: book);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Book>> _loadBooksForHolds(List<Hold> holds) async {
    final bookIds = holds.map((h) => h.bookId).toSet().toList();
    final books = <Book>[];
    
    for (final bookId in bookIds) {
      final book = await _firestoreService.getBookById(bookId);
      if (book != null) {
        books.add(book);
      }
    }
    
    return books;
  }

  Book _createPlaceholderBook() {
    return Book(
      id: '',
      title: 'Unknown Book',
      author: 'Unknown Author',
      isbn: '',
      genre: 'Unknown',
      description: '',
      pages: 0,
      language: 'English',
      status: BookStatus.available,
      section: LibrarySection.general,
      shelfLocation: '',
      totalCopies: 0,
      availableCopies: 0,
      holdCount: 0,
      coverColor: AppTheme.secondaryText,
    );
  }
}

class _HoldCard extends StatelessWidget {
  const _HoldCard({required this.hold, required this.book});
  final Hold hold;
  final Book book;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
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

    final String statusLabel;
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
