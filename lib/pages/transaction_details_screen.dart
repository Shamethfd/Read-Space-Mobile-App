import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme, PrimaryButton;
import 'package:read_space/models/payment_transaction.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  PaymentTransaction? _transaction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transaction == null) {
      final args = ModalRoute.of(context)?.settings.arguments as PaymentTransaction?;
      if (args != null) {
        setState(() => _transaction = args);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transaction == null) {
      return Scaffold(
        backgroundColor: AppTheme.pageBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Transaction Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessCard(),
            const SizedBox(height: 24),
            _buildTransactionInfo(),
            const SizedBox(height: 24),
            _buildReceiptSection(),
            const SizedBox(height: 24),
            _buildVerificationStatus(),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Download PDF Receipt',
              onPressed: _downloadReceipt,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _reportIssue,
              child: Text(
                'Report an Issue with this Payment',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    final transaction = _transaction!;
    final isApproved = transaction.status == PaymentStatus.approved;
    final isPending = transaction.status == PaymentStatus.pending;
    final isRejected = transaction.status == PaymentStatus.rejected;

    Color backgroundColor;
    Color iconColor;
    String statusText;
    String? subtitle;

    if (isApproved) {
      backgroundColor = AppTheme.success.withValues(alpha: 0.1);
      iconColor = AppTheme.success;
      statusText = transaction.statusLabel;
      subtitle = 'Paid on ${_formatDate(transaction.paymentDate)} at ${_formatTime(transaction.paymentDate)}';
    } else if (isPending) {
      backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      iconColor = const Color(0xFFF59E0B);
      statusText = transaction.statusLabel;
      subtitle = null;
    } else {
      backgroundColor = AppTheme.red.withValues(alpha: 0.1);
      iconColor = AppTheme.red;
      statusText = transaction.statusLabel;
      subtitle = null;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isApproved ? Icons.check_circle : Icons.pending,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            transaction.formattedAmount,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    final transaction = _transaction!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Transaction ID',
            value: transaction.transactionId,
            showCopy: true,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Payment Method',
            value: transaction.paymentMethod,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Reason',
            value: transaction.reason,
          ),
          if (transaction.bookTitle != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Book',
              value: transaction.bookTitle!,
            ),
          ],
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Student Details',
            value: '${transaction.memberName} (${transaction.memberId})',
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    final transaction = _transaction!;

    if (transaction.receiptUrl == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uploaded Receipt Proof',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: Open receipt image
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening receipt...')),
              );
            },
            child: Text(
              'View Full Image',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final transaction = _transaction!;

    if (transaction.status == PaymentStatus.approved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: AppTheme.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Verified by Librarian (Circulation Desk)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fine cleared. Library borrowing privileges restored.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      );
    } else if (transaction.status == PaymentStatus.pending) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
        ),
        child: Text(
          'Payment is waiting for librarian verification.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.red.withValues(alpha: 0.3)),
        ),
        child: Text(
          'Payment was rejected. Please contact the library for assistance.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
      );
    }
  }

  void _downloadReceipt() {
    // TODO: Implement PDF receipt generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF receipt generation will be implemented with backend integration'),
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue reported successfully')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showCopy = false,
  });

  final String label;
  final String value;
  final bool showCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (showCopy) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            color: AppTheme.primaryBlue,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}
