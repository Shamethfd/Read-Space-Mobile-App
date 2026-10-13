import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:read_space/main.dart' show AppTheme;
import 'package:read_space/models/book.dart';
import 'package:read_space/services/cloudinary_service.dart';

class LibrarianAddBookScreen extends StatefulWidget {
  const LibrarianAddBookScreen({super.key, this.book});

  final Book? book;

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
  bool _isUploadingImage = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  File? _coverImage;
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      // Edit mode - populate fields
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _isbnController.text = widget.book!.isbn;
      _genreController.text = widget.book!.genre;
      _languageController.text = widget.book!.language;
      _descriptionController.text = widget.book!.description;
      _copiesController.text = widget.book!.totalCopies.toString();
      _locationController.text = widget.book!.shelfLocation;
      _coverImageUrl = widget.book!.coverImageUrl;
    }
  }

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
      // Upload cover image to Cloudinary if selected
      if (_coverImage != null) {
        try {
          setState(() => _isUploadingImage = true);
          final url = await _cloudinaryService.uploadImage(
            imageFile: _coverImage!,
          );
          _coverImageUrl = url;
          print('✅ Cover image uploaded to Cloudinary successfully');
        } catch (uploadError) {
          print('⚠️ Failed to upload cover image to Cloudinary: $uploadError');
          // Continue without cover image
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cover image upload failed. Book will be added without cover.'),
                backgroundColor: AppTheme.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isUploadingImage = false);
          }
        }
      }

      if (widget.book != null) {
        // Edit mode - update existing book
        final totalCopies = int.tryParse(_copiesController.text.trim()) ?? widget.book!.totalCopies;
        final availableCopies = totalCopies - (widget.book!.totalCopies - widget.book!.availableCopies);
        
        await _firestore.collection('books').doc(widget.book!.id).update({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'isbn': _isbnController.text.trim(),
          'genre': _genreController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? 'No description'
              : _descriptionController.text.trim(),
          'language': _languageController.text.trim(),
          'shelfLocation': _locationController.text.trim(),
          'totalCopies': totalCopies,
          'availableCopies': availableCopies,
          'coverImageUrl': _coverImageUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        print('✅ Book updated in Firestore: ${widget.book!.id} - ${_titleController.text.trim()}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Book updated successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create mode - add new book
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
          coverImageUrl: _coverImageUrl,
        );

        await _firestore.collection('books').doc(book.id).set(book.toJson());

        print('✅ Book saved to Firestore: ${book.id} - ${book.title}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _coverImageUrl != null
                    ? 'Book added successfully with cover'
                    : 'Book added successfully',
              ),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('❌ Error saving book: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving book: $e'),
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

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 1200,
      );
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
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

  void _removeCoverImage() {
    setState(() {
      _coverImage = null;
      _coverImageUrl = null;
    });
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
          widget.book != null ? 'Edit Book' : 'Add Book',
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
                      GestureDetector(
                        onTap: _pickCoverImage,
                        child: Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: _coverImage != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _coverImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: _removeCoverImage,
                                        child: Container(
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
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: AppTheme.secondaryText,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload Cover',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Book Cover Image',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to upload from gallery (Optional)',
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
                    if (value!.trim().length < 2) {
                      return 'Title must be at least 2 characters';
                    }
                    if (value.trim().length > 100) {
                      return 'Title must not exceed 100 characters';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Author',
                  controller: _authorController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Author is required';
                    }
                    if (value!.trim().length < 2) {
                      return 'Author must be at least 2 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Author must not exceed 50 characters';
                    }
                    return null;
                  },
                  maxLength: 50,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'ISBN',
                  controller: _isbnController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'ISBN is required';
                    }
                    // Validate ISBN format (10 or 13 digits)
                    final isbn = value!.trim().replaceAll(RegExp(r'[-\s]'), '');
                    if (isbn.length != 10 && isbn.length != 13) {
                      return 'ISBN must be 10 or 13 digits';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(isbn)) {
                      return 'ISBN must contain only digits';
                    }
                    return null;
                  },
                  maxLength: 17, // Allows for ISBN-10 or ISBN-13 with hyphens
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Genre',
                  controller: _genreController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Genre is required';
                    }
                    if (value!.trim().length < 2) {
                      return 'Genre must be at least 2 characters';
                    }
                    if (value.trim().length > 30) {
                      return 'Genre must not exceed 30 characters';
                    }
                    return null;
                  },
                  maxLength: 30,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Language',
                  controller: _languageController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Language is required';
                    }
                    if (value!.trim().length < 2) {
                      return 'Language must be at least 2 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Language must not exceed 20 characters';
                    }
                    return null;
                  },
                  maxLength: 20,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      if (value.trim().length > 500) {
                        return 'Description must not exceed 500 characters';
                      }
                    }
                    return null;
                  },
                  maxLength: 500,
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
    int? maxLength,
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
          maxLength: maxLength,
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
