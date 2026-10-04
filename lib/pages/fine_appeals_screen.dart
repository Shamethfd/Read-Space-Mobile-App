import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes;
import 'package:read_space/models/fine_appeal.dart';
import 'package:read_space/services/firestore_service.dart';

class FineAppealsScreen extends StatefulWidget {
  const FineAppealsScreen({super.key});

  @override
  State<FineAppealsScreen> createState() => _FineAppealsScreenState();
}

class _FineAppealsScreenState extends State<FineAppealsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fine Appeals'),
        ),
        body: const Center(
          child: Text('Please login to view your appeals'),
        ),
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
          'Fine Appeals',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: StreamBuilder<List<FineAppeal>>(
        stream: _firestoreService.getUserAppealsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading appeals: ${snapshot.error}',
                style: GoogleFonts.poppins(color: AppTheme.secondaryText),
              ),
            );
          }

          final appeals = snapshot.data ?? [];

          if (appeals.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appeals.length,
            itemBuilder: (context, index) {
              return _buildAppealCard(appeals[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.submitAppeal),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: Text(
          'Submit Appeal',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 60,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Appeals Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t submitted any fine appeals.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.submitAppeal),
            icon: const Icon(Icons.add),
            label: const Text('Submit Appeal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealCard(FineAppeal appeal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Fine ID: #${appeal.fineId}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(appeal.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            appeal.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(appeal.submittedAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
              const Spacer(),
              if (appeal.proofImageUrl != null || appeal.proofDocumentUrl != null)
                Icon(
                  Icons.attach_file,
                  size: 14,
                  color: AppTheme.primaryBlue,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.appealDetails,
                    arguments: appeal,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              if (appeal.canEdit) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.submitAppeal,
                      arguments: appeal,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.orange,
                      ),
                    ),
                  ),
                ),
              ],
              if (appeal.canCancel) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(appeal),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppealStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case AppealStatus.pending:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Pending';
        break;
      case AppealStatus.approved:
        backgroundColor = const Color(0xFFD1E7DD);
        textColor = const Color(0xFF0F5132);
        label = 'Approved';
        break;
      case AppealStatus.rejected:
        backgroundColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF842029);
        label = 'Rejected';
        break;
      case AppealStatus.resolved:
        backgroundColor = const Color(0xFFD1E7DD);
        textColor = const Color(0xFF0F5132);
        label = 'Resolved';
        break;
      case AppealStatus.cancelled:
        backgroundColor = const Color(0xFFE2E3E5);
        textColor = const Color(0xFF41464B);
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCancelDialog(FineAppeal appeal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Appeal',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to withdraw this appeal?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.cancelAppeal(appeal.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appeal cancelled successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel appeal: $e'),
                      backgroundColor: AppTheme.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
