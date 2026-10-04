import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/fine_appeal.dart';
import 'package:read_space/models/notice.dart';
import 'package:read_space/services/firestore_service.dart';
import 'package:read_space/services/storage_service.dart';
import 'package:read_space/services/auth_service.dart';

class SubmitAppealScreen extends StatefulWidget {
  const SubmitAppealScreen({super.key, this.existingAppeal});

  final FineAppeal? existingAppeal;

  @override
  State<SubmitAppealScreen> createState() => _SubmitAppealScreenState();
}

class _SubmitAppealScreenState extends State<SubmitAppealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _authService = AuthService();
  final _picker = ImagePicker();

  final _fineIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  File? _proofImage;
  String? _proofImageUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAppeal != null) {
      _loadExistingAppeal();
    }
  }

  void _loadExistingAppeal() {
    final appeal = widget.existingAppeal!;
    _fineIdController.text = appeal.fineId;
    _reasonController.text = appeal.reason;
    _additionalNotesController.text = appeal.additionalNotes ?? '';
    _proofImageUrl = appeal.proofImageUrl;
  }

  @override
  void dispose() {
    _fineIdController.dispose();
    _reasonController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _proofImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProofImage(String userId, String appealId) async {
    if (_proofImage == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await _storageService.uploadImage(
        file: _proofImage!,
        path: 'fineAppeals/$userId/$appealId/proof',
        fileName: fileName,
      );
      setState(() {
        _proofImageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAppeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userData = await _authService.getUserData(user.uid);

      final appealId = widget.existingAppeal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload proof image if selected
      if (_proofImage != null) {
        await _uploadProofImage(user.uid, appealId);
      }

      final appeal = FineAppeal(
        id: appealId,
        userId: user.uid,
        userName: userData?['fullName'] ?? user.displayName ?? user.email?.split('@')[0] ?? 'User',
        userEmail: userData?['email'] ?? user.email ?? '',
        fineId: _fineIdController.text.trim(),
        reason: _reasonController.text.trim(),
        additionalNotes: _additionalNotesController.text.trim().isEmpty
            ? null
            : _additionalNotesController.text.trim(),
        proofImageUrl: _proofImageUrl,
        proofDocumentUrl: widget.existingAppeal?.proofDocumentUrl,
        status: widget.existingAppeal?.status ?? AppealStatus.pending,
        submittedAt: widget.existingAppeal?.submittedAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        resolvedAt: widget.existingAppeal?.resolvedAt,
        resolvedBy: widget.existingAppeal?.resolvedBy,
        adminResponse: widget.existingAppeal?.adminResponse,
      );

      if (widget.existingAppeal != null) {
        await _firestoreService.updateAppeal(appealId, appeal.toJson());
      } else {
        await _firestoreService.createAppeal(appeal);
        
        // Create notification for admins about new appeal
        await _createAdminNotification(appeal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAppeal != null
                  ? 'Appeal updated successfully'
                  : 'Appeal submitted successfully',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.existingAppeal != null ? "update" : "submit"} appeal: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted && !_isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createAdminNotification(FineAppeal appeal) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final notice = Notice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Fine Appeal',
        description: '${appeal.userName} has submitted a fine appeal for fine #${appeal.fineId}. Reason: ${appeal.reason}',
        category: NoticeCategory.important,
        priority: NoticePriority.normal,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'System',
        status: NoticeStatus.published,
      );
      
      await firestore.collection('notices').doc(notice.id).set(notice.toJson());
    } catch (e) {
      print('Failed to create admin notification: $e');
      // Don't fail the appeal submission if notification fails
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
          widget.existingAppeal != null ? 'Edit Appeal' : 'Submit Appeal',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFineIdField(),
              const SizedBox(height: 16),
              _buildReasonField(),
              const SizedBox(height: 16),
              _buildAdditionalNotesField(),
              const SizedBox(height: 16),
              _buildProofImageField(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting || _isUploading ? null : _submitAppeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.existingAppeal != null ? 'Update Appeal' : 'Submit Appeal',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFineIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fine ID / Reference',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fineIdController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the fine ID';
            }
            return null;
          },
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g., FINE-001',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Appeal *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the reason for appeal';
            }
            return null;
          },
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Explain why you are appealing this fine...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _additionalNotesController,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Any additional information...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProofImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proof Image (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: _proofImage != null
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _proofImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _proofImage = null;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _proofImageUrl != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                _proofImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _proofImageUrl = null;
                                });
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: AppTheme.secondaryText,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add proof image',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }
}
