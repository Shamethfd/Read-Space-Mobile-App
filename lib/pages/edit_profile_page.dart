import 'package:flutter/material.dart';

import '../main.dart' show AppRoutes, AppTheme;
import '../widgets/library_bottom_navigation.dart';
import 'member_profile_page.dart';
import 'seat_booking_flow.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.member});

  final MemberProfileData? member;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.member?.fullName ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.member?.phoneNumber ?? '',
  );
  late final _emailController = TextEditingController(
    text: widget.member?.universityEmail ?? '',
  );
  late final _facultyController = TextEditingController(
    text: widget.member?.facultyDepartment ?? '',
  );
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _reminderAlerts = true;
  bool _reservationNotifications = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _facultyController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final member = (widget.member ?? const MemberProfileData.empty()).copyWith(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      universityEmail: _emailController.text.trim(),
      facultyDepartment: _facultyController.text.trim(),
    );
    Navigator.of(context).pop(member);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _handleNavigation(int index) {
    if (index == 3) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SeatBookingFlow(),
          settings: const RouteSettings(name: AppRoutes.seatBooking),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saving ? null : _saveProfile,
            child: const Text('Save Changes'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            children: [
              ProfileHeader(member: widget.member),
              const SizedBox(height: 28),
              const SectionHeader(title: 'PERSONAL INFORMATION'),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _nameController,
                label: 'FULL NAME',
                icon: Icons.person_outline_rounded,
                validator: (value) => _required(value, 'name'),
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _phoneController,
                label: 'PHONE NUMBER',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => _required(value, 'phone number'),
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _emailController,
                label: 'UNIVERSITY EMAIL',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final requiredError = _required(value, 'email');
                  if (requiredError != null) return requiredError;
                  return value!.contains('@')
                      ? null
                      : 'Enter a valid email address';
                },
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _facultyController,
                label: 'FACULTY / DEPARTMENT',
                icon: Icons.school_outlined,
                validator: (value) => _required(value, 'faculty or department'),
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: 'SECURITY'),
              const SizedBox(height: 12),
              PasswordField(
                controller: _currentPasswordController,
                label: 'CURRENT PASSWORD',
                visible: _showCurrentPassword,
                onToggle: () => setState(
                  () => _showCurrentPassword = !_showCurrentPassword,
                ),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _newPasswordController,
                label: 'NEW PASSWORD',
                visible: _showNewPassword,
                onToggle: () =>
                    setState(() => _showNewPassword = !_showNewPassword),
                validator: (value) => _passwordValidator(value, isNew: true),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirmPasswordController,
                label: 'CONFIRM NEW PASSWORD',
                visible: _showConfirmPassword,
                onToggle: () => setState(
                  () => _showConfirmPassword = !_showConfirmPassword,
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: 'PREFERENCES'),
              const SizedBox(height: 8),
              PreferenceSwitch(
                icon: Icons.notifications_none_rounded,
                title: 'Due Date Reminder Alerts',
                value: _reminderAlerts,
                onChanged: (value) => setState(() => _reminderAlerts = value),
              ),
              PreferenceSwitch(
                icon: Icons.verified_user_outlined,
                title: 'Secure Reservation Notifications',
                value: _reservationNotifications,
                onChanged: (value) =>
                    setState(() => _reservationNotifications = value),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _saving ? null : _saveProfile,
                  child: _saving
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Profile Changes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _saving ? null : _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.red,
                    side: const BorderSide(color: AppTheme.red),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: LibraryBottomNavigation(
        selectedIndex: 3,
        onSelected: _handleNavigation,
      ),
    );
  }

  String? _required(String? value, String field) {
    return value == null || value.trim().isEmpty ? 'Enter your $field' : null;
  }

  String? _passwordValidator(String? value, {required bool isNew}) {
    if (!isNew && (value == null || value.isEmpty)) return null;
    if (value != null && value.isNotEmpty && value.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.member});

  final MemberProfileData? member;

  @override
  Widget build(BuildContext context) {
    final name = member?.fullName.trim().isNotEmpty == true
        ? member!.fullName
        : 'Library Member';
    final id = member?.memberId.trim().isNotEmpty == true
        ? member!.memberId
        : 'Member ID unavailable';

    return Column(
      children: [
        CircleAvatar(
          radius: 46,
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: .1),
          backgroundImage: member?.profileImageUrl?.isNotEmpty == true
              ? NetworkImage(member!.profileImageUrl!)
              : null,
          child: member?.profileImageUrl?.isNotEmpty == true
              ? null
              : const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: AppTheme.primaryBlue,
                ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(width: 5),
            Text(
              id,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppTheme.secondaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: .7,
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      validator: validator,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          tooltip: visible ? 'Hide password' : 'Show password',
          icon: Icon(
            visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class PreferenceSwitch extends StatelessWidget {
  const PreferenceSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.secondaryText),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
