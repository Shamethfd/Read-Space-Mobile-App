import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:read_space/main.dart' show AppTheme, AppRoutes, ReadSpaceLogo, AuthTextField, PasswordTextField, PrimaryButton;

class LibrarianLoginScreen extends StatefulWidget {
  const LibrarianLoginScreen({super.key});

  @override
  State<LibrarianLoginScreen> createState() => _LibrarianLoginScreenState();
}

class _LibrarianLoginScreenState extends State<LibrarianLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('✅ Firebase Auth successful: ${userCredential.user?.uid}');

      // Verify librarian role
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      print('📄 User doc exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        throw Exception('User document not found in Firestore');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      print('👤 User role: ${userData['role']}');

      if (userData['role'] != 'librarian') {
        await _auth.signOut();
        throw Exception('Access denied. This account is not a librarian. Role: ${userData['role']}');
      }

      print('✅ Librarian role verified, navigating to dashboard');

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.librarianDashboard);
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'Account not found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password';
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
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ReadSpaceLogo(
                          compact: true,
                          width: 180,
                          height: 66,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Librarian Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Librarian access only',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthTextField(
                          label: 'Librarian Email',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        PasswordTextField(
                          label: 'Password',
                          controller: _passwordController,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: _isLoading ? 'Signing in...' : 'Sign In',
                          onPressed: _isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Back to User Login',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
