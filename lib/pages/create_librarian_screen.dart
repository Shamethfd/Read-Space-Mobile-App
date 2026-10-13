import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:read_space/main.dart' show AppTheme;

class CreateLibrarianScreen extends StatefulWidget {
  const CreateLibrarianScreen({super.key, this.librarianData});

  final Map<String, dynamic>? librarianData;

  @override
  State<CreateLibrarianScreen> createState() => _CreateLibrarianScreenState();
}

class _CreateLibrarianScreenState extends State<CreateLibrarianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.librarianData != null) {
      // Edit mode - populate fields
      _fullNameController.text = widget.librarianData!['fullName'] ?? '';
      _emailController.text = widget.librarianData!['universityEmail'] ?? widget.librarianData!['email'] ?? '';
      _employeeIdController.text = widget.librarianData!['employeeId'] ?? '';
      _phoneController.text = widget.librarianData!['phoneNumber'] ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createLibrarian() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.librarianData != null) {
        // Edit mode - update existing librarian
        await _firestore.collection('users').doc(widget.librarianData!['uid']).update({
          'fullName': _fullNameController.text.trim(),
          'universityEmail': _emailController.text.trim().toLowerCase(),
          'employeeId': _employeeIdController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Librarian updated successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Create mode - create new librarian
        // Create Firebase Auth user (convert email to lowercase for case-insensitive matching)
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        );

        // Create Firestore user document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'universityEmail': _emailController.text.trim().toLowerCase(),
          'employeeId': _employeeIdController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'role': 'librarian',
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': true,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Librarian account created successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create librarian account';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
          widget.librarianData != null ? 'Edit Librarian' : 'Create Librarian',
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
                Text(
                  'Librarian Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  controller: _fullNameController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (value!.trim().length < 2) {
                      return 'Full name must be at least 2 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Full name must not exceed 50 characters';
                    }
                    return null;
                  },
                  maxLength: 50,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final input = (value ?? '').trim();
                    if (input.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
                    if (!emailRegex.hasMatch(input)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Employee ID',
                  icon: Icons.badge_outlined,
                  controller: _employeeIdController,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Employee ID is required';
                    }
                    if (value!.trim().length < 3) {
                      return 'Employee ID must be at least 3 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Employee ID must not exceed 20 characters';
                    }
                    return null;
                  },
                  maxLength: 20,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value!.trim().length < 10) {
                      return 'Enter a valid phone number (at least 10 digits)';
                    }
                    if (value.trim().length > 15) {
                      return 'Phone number is too long';
                    }
                    return null;
                  },
                  maxLength: 15,
                ),
                const SizedBox(height: 8),
                // Only show password fields in create mode
                if (widget.librarianData == null) ...[
                  _buildPasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    validator: (value) {
                      if ((value ?? '').length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (value!.length > 32) {
                        return 'Password must not exceed 32 characters';
                      }
                      // Check for at least one letter and one number
                      if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                        return 'Password must contain at least one letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      if ((value ?? '').length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createLibrarian,
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
                          'Create Librarian',
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
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
          maxLength: maxLength,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, color: AppTheme.secondaryText, size: 18),
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
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
          obscureText: true,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppTheme.secondaryText,
              size: 18,
            ),
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}
