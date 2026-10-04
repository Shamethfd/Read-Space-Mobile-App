import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/services/firestore_service.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});
  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _placing = false;
  bool _isSaving = false;
  final FirestoreService _firestoreService = FirestoreService();
  Book? _book;

  @override
  void initState() {
    super.initState();
    _fetchBook();
  }

  Future<void> _fetchBook() async {
    try {
      final book = await _firestoreService.getBookById(widget.bookId);
      if (mounted) {
        setState(() => _book = book);
      }
    } catch (e) {
      print('Error fetching book: $e');
    }
  }

  Future<void> _reserveOrHold(
      BuildContext context, Book book) async {
    if (book.status == BookStatus.available) {
      // Available — place directly with confirmation
      await _confirmAndPlace(context, book);
    } else {
      // Unavailable — navigate to Hold Request screen (M02 flow)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hold request feature coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmAndPlace(
      BuildContext context, Book book) async {
    // Capture before any await to satisfy use_build_context_synchronously.
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text('by ${book.author}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.secondaryText)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB39DDB)),
              ),
              child: Text(
                'DEMO — This reservation is simulated.',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF4527A0),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reserve')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _placing = true);
    try {
      // Simulate hold placement
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reserved "${_book!.title}" (demo).',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reservation failed: $e'),
          backgroundColor: AppTheme.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_book == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.pageBackground,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
          leading: const BackButton(color: AppTheme.textPrimary),
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      // ── Flat app bar per M02 (fixed light header) ─────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.pageBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actionsIconTheme: IconThemeData(color: AppTheme.textPrimary),
        leading: Semantics(
          button: true,
          label: 'Go back',
          child: BackButton(color: AppTheme.textPrimary),
        ),
        title: const Text('Book Details'),
        centerTitle: true,
        actions: [
          Semantics(
            button: true,
            label: 'Share book',
            child: IconButton(
              icon: Icon(Icons.share_outlined,
                  color: AppTheme.textPrimary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Book cover image area ──────────────────────────────────
            _BookCoverSection(book: _book!),

            // ── Book info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _book!.title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    _book!.author,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  // Star rating (4.5 — demo)
                  _StarRating(rating: 4.5, reviewCount: 48),
                  const SizedBox(height: 12),
                  // Pages · Format · Language row
                  _MetaRow(book: _book!),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 14),

                  // ── Library Status section ─────────────────────────
                  _LibraryStatusSection(book: _book!),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 14),

                  // ── Synopsis ──────────────────────────────────────
                  Text(
                    'Synopsis',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _book!.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Catalogue / Demo notice ────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFB39DDB)),
                    ),
                    child: Text(
                      'DEMO — Availability shown is simulated sample data.',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF4527A0)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── CTAs ──────────────────────────────────────────
                  if (false) ...[
                    _AlreadyHeldBanner(),
                    const SizedBox(height: 10),
                  ] else ...[
                    // Primary: Reserve / Place Hold
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _placing
                            ? null
                            : () => _reserveOrHold(context, _book!),
                        icon: _placing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.bookmark_add_rounded, size: 20),
                        label: Text(
                          _book!.status == BookStatus.available
                              ? 'Reserve / Place Hold'
                              : 'Join the Queue (${_book!.holdCount} waiting)',
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Secondary: Save Book
                  Builder(
                    builder: (context) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  setState(() => _isSaving = true);
                                  try {
                                    await Future.delayed(const Duration(milliseconds: 500));
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('"${_book!.title}" saved to your list (demo).'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.red,
                                        content: Text('Failed to save book: $e'),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) setState(() => _isSaving = false);
                                  }
                                },
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.bookmark_border_rounded, size: 20),
                          label: Text(
                            'Save Book',
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Cover Section ────────────────────────────────────────────────────────
class _BookCoverSection extends StatelessWidget {
  const _BookCoverSection({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.pageBackground,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width: 140,
          height: 190,
          decoration: BoxDecoration(
            color: book.coverColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: book.coverColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: Colors.white38, size: 52),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  book.genre.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: Colors.white60,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Star Rating ───────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.reviewCount});
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Semantics(
      label: '$rating stars, $reviewCount reviews',
      child: Row(
        children: [
          for (int i = 0; i < 5; i++)
            Icon(
              i < full
                  ? Icons.star_rounded
                  : (i == full && half)
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: 18,
              color: const Color(0xFFFFA000),
            ),
          const SizedBox(width: 6),
          Text(
            '$rating',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFA000)),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviewCount reviews)',
            style: GoogleFonts.inter(
                fontSize: 12, color: AppTheme.secondaryText),
          ),
        ],
      ),
    );
  }
}

// ── Compact Metadata Row ──────────────────────────────────────────────────────
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.pageBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetaItem(label: 'PAGES', value: book.pages.toString()),
          _divider(),
          _MetaItem(label: 'FORMAT', value: 'Hardcover'),
          _divider(),
          _MetaItem(label: 'LANGUAGE', value: book.language),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 30, color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryText,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

// ── Library Status Section — matches M02 hi-fi exactly ───────────────────────
class _LibraryStatusSection extends StatelessWidget {
  const _LibraryStatusSection({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Library Status',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: book.availableCopies > 0
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                book.availableCopies > 0 ? '• In Stock' : '• On Loan',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: book.availableCopies > 0
                      ? AppTheme.success
                      : AppTheme.orange,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Physical Location row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.place_rounded,
                  size: 16, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Physical Location',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.secondaryText)),
                Text(
                  '${_sectionLabel(book.section)} · ${book.shelfLocation}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Copies available row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle_outline_rounded,
                  size: 16, color: AppTheme.success),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: '${book.availableCopies} copies available on shelf',
              child: Text(
                book.availableCopies > 0
                    ? '${book.availableCopies} ${book.availableCopies == 1 ? 'Copy' : 'Copies'} Available on Shelf'
                    : 'No copies on shelf (${book.holdCount} on loan)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: book.availableCopies > 0
                      ? AppTheme.success
                      : AppTheme.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _sectionLabel(LibrarySection s) =>
      s == LibrarySection.quiet ? 'Quiet Zone' : 'General Section';
}

// ── Already Held Banner ───────────────────────────────────────────────────────
class _AlreadyHeldBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded,
              color: AppTheme.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You already have an active hold on this book.',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.orange),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.holds),
            child: Text('View',
                style: GoogleFonts.inter(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
