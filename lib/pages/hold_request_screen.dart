import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';

/// Hold Request screen — matches M02 hi-fi "Hold Request / Join the Queue" flow.
/// Shown when user taps "Reserve / Place Hold" on an unavailable book.
class HoldRequestScreen extends StatefulWidget {
  const HoldRequestScreen({super.key, required this.bookId});
  final String bookId;

  @override
  State<HoldRequestScreen> createState() => _HoldRequestScreenState();
}

class _HoldRequestScreenState extends State<HoldRequestScreen> {
  bool _placing = false;

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

  Book? _book() => _sampleBooks.cast<Book?>().firstWhere(
    (b) => b?.id == widget.bookId,
    orElse: () => null,
  );

  Future<void> _confirmJoin(
      BuildContext context, Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _placing = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('You joined the queue for "${book.title}" (demo).'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to join queue: $e'),
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
    final book = _book();

    if (book == null) {
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
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          leading: const BackButton(color: AppTheme.textPrimary),
          title: const Text('Hold Request'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Book not found.',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    // Demo queue position = holdCount + 1
    final queuePos = book.holdCount + 1;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
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
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppTheme.textPrimary),
        leading: const BackButton(color: AppTheme.textPrimary),
        title: const Text('Hold Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── RESERVE A COPY label ────────────────────────────────────
            Text(
              'RESERVE A COPY',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),

            // ── "Join the Queue" heading ────────────────────────────────
            Text(
              'Join the Queue',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All physical copies are currently loaned out. Join the waitlist to auto-reserve the next available copy.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // ── Book summary card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.pageBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 68,
                    decoration: BoxDecoration(
                      color: book.coverColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        color: AppTheme.secondaryText, size: 24),
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
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '• CHECKED OUT',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.red,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Queue Position ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#$queuePos',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Queue Position: #$queuePos in line',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          '${book.totalCopies} total copies · ${book.holdCount} on loan',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Estimated Availability ──────────────────────────────────
            _InfoRow(
              label: 'ESTIMATED AVAILABILITY',
              child: Row(
                children: [
                  Text(
                    '~${(queuePos * 3).clamp(2, 21)} Days (Est.)',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(Based on 3-day avg loan)',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pickup Instructions ─────────────────────────────────────
            _InfoRow(
              label: 'PICKUP INSTRUCTIONS',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BulletPoint(
                    icon: Icons.place_rounded,
                    text: 'Pickup at Main Library Circulation Desk.',
                  ),
                  const SizedBox(height: 6),
                  _BulletPoint(
                    icon: Icons.schedule_rounded,
                    text:
                        'Hold expires 48 hours after email/push notification is sent.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Demo / Live notice ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB39DDB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: Color(0xFF5E35B1)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'DEMO — This queue join is simulated. No real hold is placed.',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF4527A0)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Confirm Queue Join CTA ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _placing ? null : () => _confirmJoin(context, book),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _placing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppTheme.secondaryText, strokeWidth: 2.5))
                    : Text(
                        'Confirm Queue Join',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'By joining, you agree to our standard library checkout terms.',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.secondaryText, height: 1.4),
          ),
        ),
      ],
    );
  }
}
