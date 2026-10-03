import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/payment_transaction.dart';

class PaymentHistoryCard extends StatelessWidget {
  const PaymentHistoryCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final PaymentTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.reason,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paid on ${_formatDate(transaction.paymentDate)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(status: transaction.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case PaymentStatus.pending:
        color = const Color(0xFFF59E0B);
        break;
      case PaymentStatus.approved:
        color = AppTheme.success;
        break;
      case PaymentStatus.rejected:
        color = AppTheme.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusShortLabel(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _getStatusShortLabel() {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.approved:
        return 'Approved';
      case PaymentStatus.rejected:
        return 'Rejected';
    }
  }
}
