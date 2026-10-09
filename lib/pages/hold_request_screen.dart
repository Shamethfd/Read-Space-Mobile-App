import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_space/main.dart';
import 'package:read_space/models/book.dart';
import 'package:read_space/models/hold.dart';
import 'package:read_space/services/firestore_service.dart';

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

  Future<void> _confirmJoin(
      BuildContext context, Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please log in to place a hold'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _placing = true);
    try {
      final hold = await _firestoreService.joinHoldQueue(
        userId: userId,
        bookId: book.id,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              'You joined the queue for "${book.title}" (Position #${hold.queuePosition})'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);
    } on DuplicateHoldException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppTheme.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
    if (_book == null) {
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
          title: const Text('Loading...'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Demo queue position = holdCount + 1
    final queuePos = _book!.holdCount + 1;

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
                      color: _book!.coverColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book_rounded,
                        color: AppTheme.secondaryText, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _book!.title,
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
                          'by ${_book!.author}',
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
                  Flexible(
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
                          '${_book!.totalCopies} total copies · ${_book!.holdCount} on loan',
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

            // ── Live notice ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 14, color: AppTheme.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your hold request will be queued in real-time. You will be notified when ready for pickup.',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF166534),
                          fontWeight: FontWeight.w500),
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
                    _placing ? null : () => _confirmJoin(context, _book!),
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
