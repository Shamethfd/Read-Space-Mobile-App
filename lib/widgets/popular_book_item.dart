import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppTheme;
import '../models/analytics_data.dart';

class PopularBookItem extends StatelessWidget {
  final PopularBook book;
  final int maxCount;

  const PopularBookItem({
    super.key,
    required this.book,
    this.maxCount = 50,
  });

  @override
  Widget build(BuildContext context) {
    final progress = book.borrowCount / maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF3F4F6),
                  color: AppTheme.primaryBlue,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              book.borrowCount.toString(),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
