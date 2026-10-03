import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme;

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.title,
    required this.time,
    this.secondaryInfo,
  });

  final String title;
  final String time;
  final String? secondaryInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              if (secondaryInfo != null) ...[
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    secondaryInfo!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
