import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/fine_appeal.dart';
import 'package:read_space/services/firestore_service.dart';

class AdminAppealDetailsScreen extends StatefulWidget {
  const AdminAppealDetailsScreen({super.key, required this.appeal});

  final FineAppeal appeal;

  @override
  State<AdminAppealDetailsScreen> createState() => _AdminAppealDetailsScreenState();
}

class _AdminAppealDetailsScreenState extends State<AdminAppealDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _adminResponseController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.appeal.adminResponse != null) {
      _adminResponseController.text = widget.appeal.adminResponse!;
    }
  }

  @override
  void dispose() {
    _adminResponseController.dispose();
    super.dispose();
  }

  Future<void> _updateAppealStatus(AppealStatus newStatus) async {
    if (_adminResponseController.text.trim().isEmpty && 
        (newStatus == AppealStatus.approved || 
         newStatus == AppealStatus.rejected || 
         newStatus == AppealStatus.resolved)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add an admin response before processing'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final admin = _auth.currentUser;
      if (admin == null) {
        throw Exception('Admin not authenticated');
      }

      final updateData = {
        'status': newStatus.name,
        'updatedAt': DateTime.now().toIso8601String(),
        'adminResponse': _adminResponseController.text.trim(),
      };

      if (newStatus == AppealStatus.resolved ||
          newStatus == AppealStatus.approved ||
          newStatus == AppealStatus.rejected) {
        updateData['resolvedAt'] = DateTime.now().toIso8601String();
        updateData['resolvedBy'] = admin.uid;
      }

      await _firestoreService.updateAppeal(widget.appeal.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appeal ${newStatus.name} successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appeal: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Appeal Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildStudentInfoCard(),
            const SizedBox(height: 16),
            _buildFineInfoCard(),
            const SizedBox(height: 16),
            _buildReasonCard(),
            const SizedBox(height: 16),
            if (widget.appeal.additionalNotes != null && 
                widget.appeal.additionalNotes!.isNotEmpty)
              _buildAdditionalNotesCard(),
            const SizedBox(height: 16),
            if (widget.appeal.proofImageUrl != null) _buildProofImageCard(),
            const SizedBox(height: 16),
            _buildAdminResponseCard(),
            const SizedBox(height: 24),
            if (widget.appeal.status == AppealStatus.pending)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
          _buildStatusBadge(widget.appeal.status),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
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
            'Student Information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', widget.appeal.userName),
          const SizedBox(height: 8),
          _buildInfoRow('Email', widget.appeal.userEmail),
          const SizedBox(height: 8),
          _buildInfoRow('User ID', widget.appeal.userId),
        ],
      ),
    );
  }

  Widget _buildFineInfoCard() {
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
            'Fine Information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Fine ID', '#${widget.appeal.fineId}'),
          const SizedBox(height: 8),
          _buildInfoRow('Submitted', _formatDate(widget.appeal.submittedAt)),
          const SizedBox(height: 8),
          _buildInfoRow('Last Updated', _formatDate(widget.appeal.updatedAt)),
          if (widget.appeal.resolvedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Resolved', _formatDate(widget.appeal.resolvedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.secondaryText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCard() {
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
            'Reason for Appeal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.appeal.reason,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotesCard() {
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
            'Additional Notes',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.appeal.additionalNotes!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofImageCard() {
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
            'Proof Image',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.appeal.proofImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Failed to load image',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminResponseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Admin Response',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _adminResponseController,
            maxLines: 5,
            enabled: widget.appeal.status == AppealStatus.pending,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: widget.appeal.status == AppealStatus.pending
                  ? 'Add your response here...'
                  : '',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.secondaryText,
              ),
              filled: true,
              fillColor: widget.appeal.status == AppealStatus.pending
                  ? Colors.white
                  : const Color(0xFFF3F4F6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          if (widget.appeal.adminResponse != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.appeal.adminResponse!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isProcessing ? null : () => _updateAppealStatus(AppealStatus.approved),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Approve Appeal',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isProcessing ? null : () => _updateAppealStatus(AppealStatus.resolved),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Resolve Appeal',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _isProcessing ? null : () => _updateAppealStatus(AppealStatus.rejected),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.red,
            side: const BorderSide(color: AppTheme.red),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.red),
                  ),
                )
              : Text(
                  'Reject Appeal',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
