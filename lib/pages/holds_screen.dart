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

          return FutureBuilder<Map<String, Book>>(
            future: _loadBooksMapForHolds(holds),
            builder: (context, booksSnapshot) {
              if (booksSnapshot.connectionState == ConnectionState.waiting &&
                  _bookCache.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final booksMap = booksSnapshot.data ?? _bookCache;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: holds.length,
                itemBuilder: (context, index) {
                  final hold = holds[index];
                  final book = booksMap[hold.bookId] ??
                      _createPlaceholderBook(hold.bookId);
                  return _HoldCard(
                    hold: hold,
                    book: book,
                    onCancelled: () => setState(() {}),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  final Map<String, Book> _bookCache = {};

  Future<Map<String, Book>> _loadBooksMapForHolds(List<Hold> holds) async {
    final bookIds = holds.map((h) => h.bookId).toSet().toList();
    for (final bookId in bookIds) {
      if (!_bookCache.containsKey(bookId) && bookId.isNotEmpty) {
        try {
          final book = await _firestoreService.getBookById(bookId);
          if (book != null) {
            _bookCache[bookId] = book;
          }
        } catch (_) {}
      }
    }
    return _bookCache;
  }

  Book _createPlaceholderBook(String bookId) {
    return Book(
      id: bookId,
      title: 'Book #$bookId',
      author: 'Library Book',
      isbn: '',
      genre: 'General',
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

class _HoldCard extends StatefulWidget {
  const _HoldCard({
    required this.hold,
    required this.book,
    this.onCancelled,
  });

  final Hold hold;
  final Book book;
  final VoidCallback? onCancelled;

  @override
  State<_HoldCard> createState() => _HoldCardState();
}

class _HoldCardState extends State<_HoldCard> {
  bool _cancelling = false;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _confirmCancel(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Hold'),
        content: Text(
          'Are you sure you want to cancel your hold for "${widget.book.title}"?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Hold'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Hold'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await _firestoreService.cancelHold(widget.hold.id);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Hold cancelled successfully.'),
          backgroundColor: AppTheme.success,
        ),
      );
      widget.onCancelled?.call();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to cancel hold: $e'),
          backgroundColor: AppTheme.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hold = widget.hold;
    final book = widget.book;

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

    final canCancel =
        hold.holdStatus == HoldStatus.pending || hold.holdStatus == HoldStatus.ready;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: book.id.isNotEmpty
            ? () => Navigator.pushNamed(
                  context,
                  AppRoutes.bookDetail,
                  arguments: book.id,
                )
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 11,
                                    color: AppTheme.secondaryText,
                                    fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (canCancel) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _cancelling ? null : () => _confirmCancel(context),
                    icon: _cancelling
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close_rounded,
                            size: 16, color: AppTheme.red),
                    label: Text(
                      'Cancel Hold',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
