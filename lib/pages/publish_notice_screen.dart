import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/main.dart' show AppTheme, PrimaryButton;
import 'package:read_space/models/notice.dart';
import 'package:read_space/services/notice_service.dart';

class PublishNoticeScreen extends StatefulWidget {
  const PublishNoticeScreen({super.key});

  @override
  State<PublishNoticeScreen> createState() => _PublishNoticeScreenState();
}

class _PublishNoticeScreenState extends State<PublishNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noticeService = NoticeService();

  NoticeCategory _selectedCategory = NoticeCategory.general;
  NoticePriority _selectedPriority = NoticePriority.normal;
  DateTime? _eventDate;
  DateTime? _expiryDate;
  String? _attachmentUrl;

  bool _isLoading = false;
  bool _isSavingDraft = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _publishNotice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notice = Notice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        eventDate: _eventDate,
        expiryDate: _expiryDate,
        createdBy: 'Admin', // TODO: Get from auth service
        status: NoticeStatus.published,
        attachmentUrl: _attachmentUrl,
      );

      await _noticeService.createNotice(notice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice published successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to publish notice. Please try again.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSavingDraft = true);

    try {
      final notice = Notice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        eventDate: _eventDate,
        expiryDate: _expiryDate,
        createdBy: 'Admin', // TODO: Get from auth service
        status: NoticeStatus.draft,
        attachmentUrl: _attachmentUrl,
      );

      await _noticeService.createNotice(notice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully.'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save draft. Please try again.'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingDraft = false);
      }
    }
  }

  Future<void> _selectDate({required bool isEventDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isEventDate) {
          _eventDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
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
          'Publish New Notice',
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
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildPriorityDropdown(),
              const SizedBox(height: 16),
              _buildEventDatePicker(),
              const SizedBox(height: 16),
              _buildExpiryDatePicker(),
              const SizedBox(height: 16),
              _buildAttachmentField(),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _isLoading ? 'Publishing...' : 'Publish Notice',
                onPressed: _isLoading ? null : _publishNotice,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSavingDraft ? null : _saveDraft,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSavingDraft ? 'Saving...' : 'Save Draft',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notice Title',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g., Library Closure on Public Holiday',
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

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NoticeCategory>(
              value: _selectedCategory,
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
              items: NoticeCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryLabel(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter the notice details...',
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

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NoticePriority>(
              value: _selectedPriority,
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
              items: NoticePriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityLabel(priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(isEventDate: true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _eventDate != null
                        ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                        : 'Select event date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _eventDate != null ? AppTheme.textPrimary : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(isEventDate: false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expiryDate != null
                        ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                        : 'Select expiry date',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _expiryDate != null ? AppTheme.textPrimary : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Implement file upload
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File upload will be implemented with backend integration.'),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppTheme.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _attachmentUrl != null ? 'File attached' : 'Attach a file',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _attachmentUrl != null ? AppTheme.textPrimary : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.general:
        return 'General';
      case NoticeCategory.important:
        return 'Important';
      case NoticeCategory.library:
        return 'Library';
      case NoticeCategory.events:
        return 'Events';
      case NoticeCategory.maintenance:
        return 'Maintenance';
      case NoticeCategory.academic:
        return 'Academic';
    }
  }

  String _getPriorityLabel(NoticePriority priority) {
    switch (priority) {
      case NoticePriority.normal:
        return 'Normal';
      case NoticePriority.important:
        return 'Important';
      case NoticePriority.urgent:
        return 'Urgent';
    }
  }
}
