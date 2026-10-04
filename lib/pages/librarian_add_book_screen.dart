import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/book.dart';

class LibrarianAddBookScreen extends StatefulWidget {
  const LibrarianAddBookScreen({super.key});

  @override
  State<LibrarianAddBookScreen> createState() => _LibrarianAddBookScreenState();
}

class _LibrarianAddBookScreenState extends State<LibrarianAddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _genreController = TextEditingController();
  final _languageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _genreController.dispose();
    _languageController.dispose();
    _descriptionController.dispose();
    _copiesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        genre: _genreController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'No description' 
            : _descriptionController.text.trim(),
        pages: 200,
        language: _languageController.text.trim(),
        status: BookStatus.available,
        section: LibrarySection.general,
        shelfLocation: _locationController.text.trim(),
        totalCopies: int.tryParse(_copiesController.text.trim()) ?? 1,
        availableCopies: int.tryParse(_copiesController.text.trim()) ?? 1,
        holdCount: 0,
        coverColor: const Color(0xFF0787F5),
      );

      await _firestore.collection('books').doc(book.id).set(book.toJson());

      print('✅ Book saved to Firestore: ${book.id} - ${book.title}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book added successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error adding book: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding book: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        ),
        title: Text(
          'Add Book',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Upload Book Cover',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to upload or choose from gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Book Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Title',
                  controller: _titleController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Author',
                  controller: _authorController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Author is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'ISBN',
                  controller: _isbnController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'ISBN is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Genre',
                  controller: _genreController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Genre is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Language',
                  controller: _languageController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Language is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Total Copies',
                        controller: _copiesController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Copies is required';
                          }
                          final copies = int.tryParse(value!);
                          if (copies == null || copies < 1) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        label: 'Shelf / Location',
                        controller: _locationController,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Location is required';
                          }
                            return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add Book',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}
