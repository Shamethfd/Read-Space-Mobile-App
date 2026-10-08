import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_space/firebase_options.dart';
import 'package:read_space/models/fine_appeal.dart';
import 'package:read_space/pages/admin_appeal_details_screen.dart';
import 'package:read_space/pages/admin_appeals_screen.dart';
import 'package:read_space/pages/admin_dashboard_screen.dart';
import 'package:read_space/pages/admin_notices_screen.dart';
import 'package:read_space/pages/appeal_details_screen.dart';
import 'package:read_space/pages/book_detail_screen.dart';
import 'package:read_space/pages/catalogue_screen.dart';
import 'package:read_space/pages/create_librarian_screen.dart';
import 'package:read_space/pages/dashboard_page.dart';
import 'package:read_space/pages/edit_notice_screen.dart';
import 'package:read_space/pages/edit_profile_page.dart';
import 'package:read_space/pages/fine_appeals_screen.dart';
import 'package:read_space/pages/hold_request_screen.dart';
import 'package:read_space/pages/holds_screen.dart';
import 'package:read_space/pages/librarian_add_book_screen.dart';
import 'package:read_space/pages/librarian_dashboard_screen.dart';
import 'package:read_space/pages/librarian_inventory_screen.dart';
import 'package:read_space/pages/librarian_profile_screen.dart';
import 'package:read_space/pages/manage_seat_reservation_screen.dart';
import 'package:read_space/pages/member_profile_page.dart';
import 'package:read_space/pages/my_reservations_screen.dart';
import 'package:read_space/pages/notice_details_screen.dart';
import 'package:read_space/pages/notifications_screen.dart';
import 'package:read_space/pages/pay_library_fine_screen.dart';
import 'package:read_space/pages/publish_notice_screen.dart';
import 'package:read_space/pages/submit_appeal_screen.dart';
import 'package:read_space/pages/transaction_details_screen.dart';
import 'package:read_space/pages/seat_booking_flow.dart';
import 'package:read_space/pages/librarian_analytics_screen.dart';
import 'package:read_space/pages/seat_occupancy_screen.dart';
import 'package:read_space/services/admin_auth_service.dart';
import 'package:read_space/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ReadSpaceApp());
}

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const adminLogin = '/admin-login';
  static const adminDashboard = '/admin-dashboard';
  static const adminNotices = '/admin-notices';
  static const publishNotice = '/publish-notice';
  static const editNotice = '/edit-notice';
  static const notifications = '/notifications';
  static const noticeDetails = '/notice-details';
  static const payLibraryFine = '/pay-library-fine';
  static const transactionDetails = '/transaction-details';
  static const librarianLogin = '/librarian-login';
  static const librarianDashboard = '/librarian-dashboard';
  static const librarianProfile = '/librarian-profile';
  static const librarianInventory = '/librarian-inventory';
  static const librarianAddBook = '/librarian-add-book';
  static const createLibrarian = '/create-librarian';
  static const catalogue = '/catalogue';
  static const bookDetail = '/book-detail';
  static const holdRequest = '/hold-request';
  static const holds = '/holds';
  static const fineAppeals = '/fine-appeals';
  static const submitAppeal = '/submit-appeal';
  static const appealDetails = '/appeal-details';
  static const adminAppeals = '/admin-appeals';
  static const adminAppealDetails = '/admin-appeal-details';
  static const seatBooking = '/seat-booking';
  static const myReservations = '/my-reservations';
  static const manageSeatReservation = '/manage-seat-reservation';
  static const librarianAnalytics = '/librarian-analytics';
  static const seatOccupancy = '/seat-occupancy';
}

class AppTheme {
  static const Color primaryBlue = Color(0xFF0787F5);
  static const Color darkBlue = Color(0xFF0066CC);
  static const Color orange = Color(0xFFF7941D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color pageBackground = Color(0xFFF8F9FB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color red = Color(0xFFFF3B30);
  static const Color success = Color(0xFF16A34A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBackground,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: orange,
        surface: white,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: GoogleFonts.poppinsTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class ReadSpaceApp extends StatelessWidget {
  const ReadSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadSpace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Uri.base.fragment.split('?').first == AppRoutes.seatBooking
          ? AppRoutes.seatBooking
          : AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.signup: (_) => const SignUpScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.dashboard: (_) => const DashboardPage(),
        AppRoutes.profile: (_) => const MemberProfilePage(),
        AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
        AppRoutes.adminNotices: (_) => const AdminNoticesScreen(),
        AppRoutes.publishNotice: (_) => const PublishNoticeScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.payLibraryFine: (_) => const PayLibraryFineScreen(),
        AppRoutes.librarianLogin: (_) => const LibrarianLoginScreen(),
        AppRoutes.librarianDashboard: (_) => const LibrarianDashboardScreen(),
        AppRoutes.librarianProfile: (_) => const LibrarianProfileScreen(),
        AppRoutes.librarianInventory: (_) => const LibrarianInventoryScreen(),
        AppRoutes.librarianAddBook: (_) => const LibrarianAddBookScreen(),
        AppRoutes.createLibrarian: (_) => const CreateLibrarianScreen(),
        AppRoutes.catalogue: (_) => const CatalogueScreen(),
        AppRoutes.holds: (_) => const HoldsScreen(),
        AppRoutes.fineAppeals: (_) => const FineAppealsScreen(),
        AppRoutes.submitAppeal: (_) => const SubmitAppealScreen(),
        AppRoutes.adminAppeals: (_) => const AdminAppealsScreen(),
        AppRoutes.seatBooking: (_) => const SeatBookingFlow(),
        AppRoutes.myReservations: (_) => const MyReservationsScreen(),
        AppRoutes.librarianAnalytics: (_) => const LibrarianAnalyticsScreen(),
        AppRoutes.seatOccupancy: (_) => const SeatOccupancyScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.editProfile) {
          final member = settings.arguments is MemberProfileData
              ? settings.arguments as MemberProfileData
              : null;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) => EditProfilePage(member: member),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.editNotice) {
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) => const EditNoticeScreen(),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.noticeDetails) {
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) => const NoticeDetailsScreen(),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.transactionDetails) {
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) => const TransactionDetailsScreen(),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.bookDetail) {
          final bookId = settings.arguments as String?;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                BookDetailScreen(bookId: bookId ?? ''),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.holdRequest) {
          final bookId = settings.arguments as String?;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                HoldRequestScreen(bookId: bookId ?? ''),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.submitAppeal) {
          final existingAppeal = settings.arguments as FineAppeal?;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                SubmitAppealScreen(existingAppeal: existingAppeal),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.appealDetails) {
          final appeal = settings.arguments as FineAppeal;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                AppealDetailsScreen(appeal: appeal),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.adminAppealDetails) {
          final appeal = settings.arguments as FineAppeal;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                AdminAppealDetailsScreen(appeal: appeal),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        if (settings.name == AppRoutes.manageSeatReservation) {
          final bookingId = settings.arguments as String?;
          return PageRouteBuilder<void>(
            settings: settings,
            pageBuilder: (_, animation, _) =>
                ManageSeatReservationScreen(bookingId: bookingId ?? ''),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        }
        return null;
      },
    );
  }
}

class ReadSpaceLogo extends StatelessWidget {
  const ReadSpaceLogo({
    super.key,
    this.width,
    this.height,
    this.compact = false,
  });

  final double? width;
  final double? height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? (compact ? 170.0 : 220.0);
    final cardHeight = height ?? (compact ? 72.0 : 94.0);

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/readspace_logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.logoCompact = false,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;
  final bool logoCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          ReadSpaceLogo(
            compact: logoCompact,
            width: 180,
            height: logoCompact ? 64 : 82,
          ),
          const SizedBox(height: 18),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.hintText,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? hintText;
  final TextInputAction? textInputAction;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
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
          obscureText: obscureText,
          textInputAction: textInputAction ?? TextInputAction.next,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
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
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscured,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppTheme.secondaryText,
              size: 18,
            ),
            suffixIcon: IconButton(
              splashRadius: 16,
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.secondaryText,
                size: 18,
              ),
              onPressed: () => setState(() => _obscured = !_obscured),
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

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final btnColor = backgroundColor ?? AppTheme.primaryBlue;
    final textColor = foregroundColor ?? AppTheme.white;

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: textColor,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        // Always go to onboarding - user must login explicitly
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding_students.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -70),
              child: const ReadSpaceLogo(width: 220, height: 96),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ReadSpaceLogo(width: 180, height: 76),
              const SizedBox(height: 18),
              Text(
                'Welcome to ReadSpace — your smart library companion.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 34),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'assets/images/onboarding_students.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: PrimaryButton(
                        label: 'Get Started',
                        width: 230,
                        backgroundColor: AppTheme.orange,
                        foregroundColor: Colors.white,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.signup),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      setState(() => _isLoading = true);
      try {
        await _authService.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          studentId: _studentIdController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } catch (e) {
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
    } else if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the library terms and privacy policy.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
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
                        const SizedBox(height: 18),
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register now for university library services',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 26),
                        AuthTextField(
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          controller: _fullNameController,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Full name cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        AuthTextField(
                          label: 'Student ID / UID',
                          icon: Icons.badge_outlined,
                          controller: _studentIdController,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Student ID cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        AuthTextField(
                          label: 'University Email Address',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final input = (value ?? '').trim();
                            if (input.isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailRegex.hasMatch(input)) {
                              return 'Enter a valid university email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        PasswordTextField(
                          label: 'Create Password',
                          controller: _passwordController,
                          validator: (value) {
                            if ((value ?? '').length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Checkbox(
                                value: _termsAccepted,
                                activeColor: AppTheme.primaryBlue,
                                onChanged: (value) {
                                  setState(
                                    () => _termsAccepted = value ?? false,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _termsAccepted = !_termsAccepted,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: AppTheme.secondaryText,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Library Terms & Privacy Policy',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        PrimaryButton(
                          label: _isLoading
                              ? 'Creating Account...'
                              : 'Create Account',
                          onPressed: _isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, AppRoutes.login),
                              child: Text(
                                'Log in',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        print('✅ Login successful');

        // Check user role and redirect accordingly
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('👤 User UID: ${user.uid}');

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          print('📄 User doc exists: ${userDoc.exists}');

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final role = userData['role'];
            print('👤 User role: $role');

            if (mounted) {
              if (role == 'librarian') {
                print('🚀 Navigating to Librarian Dashboard');
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.librarianDashboard,
                );
              } else if (role == 'admin') {
                print('🚀 Navigating to Admin Dashboard');
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminDashboard,
                );
              } else {
                print('🚀 Navigating to User Dashboard');
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              }
            }
          } else {
            print('⚠️ User doc not found, going to User Dashboard');
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
          }
        } else {
          print('⚠️ No current user, going to User Dashboard');
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        }
      } catch (e) {
        print('❌ Login error: $e');
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
                          'ReadSpace',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Sign in to access library services',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthTextField(
                          label: 'University Email / Library ID',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) {
                              return 'Please enter your email or library ID';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 6),
                        PasswordTextField(
                          label: 'Password',
                          controller: _passwordController,
                          validator: (value) {
                            if ((value ?? '').isEmpty) {
                              return 'Please enter your password';
                            }
                            if ((value ?? '').length < 6) {
                              return 'Password is too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 22),
                        PrimaryButton(
                          label: _isLoading ? 'Signing In...' : 'Sign In',
                          onPressed: _isLoading ? null : _submit,
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New to ReadSpace? ',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.signup,
                                ),
                                child: Text(
                                  'Sign up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Are you a Librarian? ',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.librarianLogin,
                              ),
                              child: Text(
                                'Login as Librarian',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            Text(
                              'Are you an Admin?',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminLogin,
                              ),
                              child: Text(
                                'Sign in here',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
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

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminAuthService = AdminAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _adminAuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
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
                          'Admin Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin access only',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthTextField(
                          label: 'Admin Email / ID',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your admin email or ID';
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
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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

class LibrarianLoginScreen extends StatefulWidget {
  const LibrarianLoginScreen({super.key});

  @override
  State<LibrarianLoginScreen> createState() => _LibrarianLoginScreenState();
}

class _LibrarianLoginScreenState extends State<LibrarianLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
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
                        Text(
                          'ReadSpace',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome Staff! Sign in to access library services',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthTextField(
                          label: 'University Email / Library ID',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Please enter your email or library ID';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        PasswordTextField(
                          label: 'Password',
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
                          label: 'Sign In',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Need help? Contact library',
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
