import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;

class BankInfoCard extends StatelessWidget {
  const BankInfoCard({
    super.key,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.referenceCode,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final String referenceCode;

  @override
  Widget build(BuildContext context) {
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
            'Bank Transfer Information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'BANK NAME',
            value: bankName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'ACCOUNT NAME',
            value: accountName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'ACCOUNT NUMBER',
            value: accountNumber,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'REFERENCE CODE',
            value: referenceCode,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
    );
  }
}
