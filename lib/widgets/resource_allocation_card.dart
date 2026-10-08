import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppTheme;

class ResourceAllocationCard extends StatelessWidget {
  final int occupied;
  final int available;
  final int reserved;
  final int unavailable;

  const ResourceAllocationCard({
    super.key,
    required this.occupied,
    required this.available,
    required this.reserved,
    required this.unavailable,
  });

  @override
  Widget build(BuildContext context) {
    final total = occupied + available + reserved + unavailable;

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
            'Resource Allocation',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildResourceRow('Occupied', occupied, AppTheme.primaryBlue, total),
          const SizedBox(height: 12),
          _buildResourceRow('Available', available, AppTheme.success, total),
          const SizedBox(height: 12),
          _buildResourceRow('Reserved', reserved, AppTheme.orange, total),
          const SizedBox(height: 12),
          _buildResourceRow('Unavailable', unavailable, AppTheme.red, total),
        ],
      ),
    );
  }

  Widget _buildResourceRow(String label, int value, Color color, int total) {
    final percentage = total > 0 ? (value / total * 100).toInt() : 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
