import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart' show AppTheme, AppRoutes;
import '../widgets/library_bottom_navigation.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';

typedef MemberProfileLoader = Future<MemberProfileData> Function();

class MemberProfileData {
  const MemberProfileData({
    required this.fullName,
    required this.memberId,
    this.profileImageUrl,
    this.phoneNumber = '',
    this.universityEmail = '',
    this.facultyDepartment = '',
    this.outstandingFines = 0,
    this.borrowingHistory = const [],
  });

  const MemberProfileData.empty()
    : fullName = '',
      memberId = '',
      profileImageUrl = null,
      phoneNumber = '',
      universityEmail = '',
      facultyDepartment = '',
      outstandingFines = 0,
      borrowingHistory = const [];

  final String fullName;
  final String memberId;
  final String? profileImageUrl;
  final String phoneNumber;
  final String universityEmail;
  final String facultyDepartment;
  final double outstandingFines;
  final List<BorrowedBook> borrowingHistory;

  MemberProfileData copyWith({
    String? fullName,
    String? memberId,
    String? profileImageUrl,
    String? phoneNumber,
    String? universityEmail,
    String? facultyDepartment,
    double? outstandingFines,
    List<BorrowedBook>? borrowingHistory,
  }) {
    return MemberProfileData(
      fullName: fullName ?? this.fullName,
      memberId: memberId ?? this.memberId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      universityEmail: universityEmail ?? this.universityEmail,
      facultyDepartment: facultyDepartment ?? this.facultyDepartment,
      outstandingFines: outstandingFines ?? this.outstandingFines,
      borrowingHistory: borrowingHistory ?? this.borrowingHistory,
    );
  }

  static MemberProfileData fromUserProfile(UserProfile userProfile, double outstandingFines) {
    return MemberProfileData(
      fullName: userProfile.fullName,
      memberId: userProfile.studentId,
      profileImageUrl: userProfile.profileImageUrl,
      phoneNumber: userProfile.phoneNumber,
      universityEmail: userProfile.universityEmail,
      facultyDepartment: userProfile.facultyDepartment,
      outstandingFines: outstandingFines,
      borrowingHistory: const [],
    );
  }
}

enum BorrowingStatus { active, overdue, returned }

class BorrowedBook {
  const BorrowedBook({
    required this.title,
    required this.author,
    required this.status,
    required this.dateLabel,
  });

  final String title;
  final String author;
  final BorrowingStatus status;
  final String dateLabel;
}

class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({
    super.key,
    this.member,
    this.loadProfile,
    this.onPayOnline,
    this.onSeeAllHistory,
  });

  final MemberProfileData? member;
  final MemberProfileLoader? loadProfile;
  final VoidCallback? onPayOnline;
  final VoidCallback? onSeeAllHistory;

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  late MemberProfileData? _member = widget.member;
  Object? _error;
  bool _loading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    if (widget.loadProfile != null) {
      _loadProfile();
    } else {
      _loadFromFirestore();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final member = await widget.loadProfile!();
      if (!mounted) return;
      setState(() {
        _member = member;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Not logged in';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('Loading profile for user: ${user.uid}');
      print('User email: ${user.email}');
      print('User display name: ${user.displayName}');
      
      final userData = await _firestoreService.getUserById(user.uid);
      print('User data from Firestore: ${userData != null ? "Found" : "Not found"}');
      
      if (userData != null) {
        print('User data keys: ${userData.keys.toList()}');
      }
      
      final outstandingFines = await _paymentService.getOutstandingFines(user.uid);
      print('Outstanding fines: $outstandingFines');

      if (!mounted) return;

      if (userData != null) {
        final userProfile = UserProfile.fromJson(userData);
        setState(() {
          _member = MemberProfileData.fromUserProfile(userProfile, outstandingFines);
          _loading = false;
        });
        print('Profile loaded successfully');
      } else {
        print('User document not found in Firestore, using Firebase Auth data');
        setState(() {
          _member = MemberProfileData(
            fullName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
            memberId: '',
            universityEmail: user.email ?? '',
            outstandingFines: outstandingFines,
          );
          _loading = false;
        });
      }
    } on FirebaseException catch (e) {
      print('Firebase error loading profile: ${e.code} - ${e.message}');
      if (!mounted) return;
      setState(() {
        _error = 'Firebase configuration error. Please check google-services.json';
        _loading = false;
      });
    } catch (error) {
      print('Error loading profile: $error');
      print('Error type: ${error.runtimeType}');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load profile. Using basic info.';
        _loading = false;
        _member = MemberProfileData(
          fullName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
          memberId: '',
          universityEmail: user.email ?? '',
          outstandingFines: 0,
        );
      });
    }
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text('Member Profile'),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _ProfileContent(
                member: _member ?? const MemberProfileData.empty(),
                onEditProfile: () => Navigator.of(context).pushNamed(
                  AppRoutes.editProfile,
                  arguments: _member ?? const MemberProfileData.empty(),
                ),
                onPayOnline: () {
                  if (widget.onPayOnline != null) {
                    widget.onPayOnline!();
                  } else {
                    Navigator.pushNamed(context, AppRoutes.payLibraryFine);
                  }
                },
                onSeeAllHistory: widget.onSeeAllHistory,
              ),
      ),
      bottomNavigationBar: LibraryBottomNavigation(
        selectedIndex: 3,
        onSelected: _handleNavigation,
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.member,
    required this.onEditProfile,
    this.onPayOnline,
    this.onSeeAllHistory,
  });

  final MemberProfileData member;
  final VoidCallback onEditProfile;
  final VoidCallback? onPayOnline;
  final VoidCallback? onSeeAllHistory;

  @override
  Widget build(BuildContext context) {
    final hasMember =
        member.fullName.trim().isNotEmpty || member.memberId.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        _MemberCard(member: member, hasMember: hasMember, onTap: onEditProfile),
        const SizedBox(height: 16),
        _FinesCard(balance: member.outstandingFines, onPayOnline: onPayOnline),
        const SizedBox(height: 16),
        _AppealsCard(),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Borrowing History',
          action: 'See All',
          onPressed: member.borrowingHistory.isEmpty ? null : onSeeAllHistory,
        ),
        const SizedBox(height: 12),
        if (member.borrowingHistory.isEmpty)
          const _EmptyHistoryState()
        else
          for (final book in member.borrowingHistory) ...[
            _BorrowedBookCard(book: book),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.hasMember,
    required this.onTap,
  });

  final MemberProfileData member;
  final bool hasMember;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = hasMember && member.fullName.isNotEmpty
        ? member.fullName
        : 'Member details unavailable';
    final id = member.memberId.isNotEmpty
        ? member.memberId
        : 'Member ID not available';

    return Semantics(
      button: true,
      label: 'Edit member profile',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProfileAvatar(imageUrl: member.profileImageUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          id,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(height: 1),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QrCode(memberId: member.memberId),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Digital Library Card',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Present this QR code at the desk or scanner to borrow books and check in to desks.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.45,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.person_rounded,
      color: Theme.of(context).colorScheme.primary,
      size: 34,
    );
    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: .1),
      backgroundImage: imageUrl == null || imageUrl!.isEmpty
          ? null
          : NetworkImage(imageUrl!),
      child: imageUrl == null || imageUrl!.isEmpty ? fallback : null,
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    if (memberId.trim().isEmpty) {
      return Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.qr_code_2_rounded,
          color: Colors.grey.shade400,
          size: 45,
        ),
      );
    }
    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(6),
      color: Colors.white,
      child: QrImageView(data: memberId, version: QrVersions.auto),
    );
  }
}

class _FinesCard extends StatelessWidget {
  const _FinesCard({required this.balance, this.onPayOnline});

  final double balance;
  final VoidCallback? onPayOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBalance = balance > 0;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Outstanding Fines Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasBalance)
                const _StatusLabel(
                  text: 'ACTION REQUIRED',
                  color: Color(0xFFF59E0B),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'LKR ${balance.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hasBalance ? 'Overdue charges accrued' : 'No outstanding fines',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPayOnline,
              style: FilledButton.styleFrom(
                backgroundColor: hasBalance ? null : theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              child: Text(hasBalance ? 'Pay Online' : 'View Payment History'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppealsCard extends StatelessWidget {
  const _AppealsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SurfaceCard(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.fineAppeals),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.gavel_outlined,
                  color: AppTheme.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fine Appeals',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submit or view your fine appeals',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BorrowedBookCard extends StatelessWidget {
  const _BorrowedBookCard({required this.book});

  final BorrowedBook book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusDetails(book.status, theme);
    return _SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  book.dateLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusLabel(text: status.$1, color: status.$2),
        ],
      ),
    );
  }

  (String, Color) _statusDetails(BorrowingStatus status, ThemeData theme) {
    switch (status) {
      case BorrowingStatus.active:
        return ('Active', theme.colorScheme.primary);
      case BorrowingStatus.overdue:
        return ('Overdue', const Color(0xFFF59E0B));
      case BorrowingStatus.returned:
        return ('Returned', const Color(0xFF18A66A));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    this.onPressed,
  });

  final String title;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No borrowing history yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 42),
            const SizedBox(height: 12),
            const Text('Unable to load member profile.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
