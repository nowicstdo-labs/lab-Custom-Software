import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/auth_models.dart';
import '../../auth/auth_provider.dart';
import '../../auth/auth_service.dart';

// Staff roles available to an admin (patients are self-registered)
const _staffRoles = [
  UserRole.doctor,
  UserRole.receptionist,
  UserRole.labTechnician,
  UserRole.admin,
];

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.doctor;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Trigger rebuild of the staff list after creation
  int _listVersion = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateStaff() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).addStaffMember(
            name: name,
            email: email,
            phone: phone,
            password: password,
            role: _selectedRole,
          );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _listVersion++; // force staff list to rebuild
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _passwordController.clear();
          _selectedRole = UserRole.doctor;
        });
        _showSnackBar('Staff member created successfully!', success: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? AppColors.secondary : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Form Card ─────────────────────────────────────────────────────
            _SectionHeader(title: 'Add New Staff Member', icon: Icons.person_add_alt_1_rounded),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  AppTextField(
                    label: 'Full Name',
                    hint: 'e.g. Dr. Ananya Bose',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),

                  // Email
                  AppTextField(
                    label: 'Email Address',
                    hint: 'staff@astha.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),

                  // Phone
                  AppTextField(
                    label: 'Phone Number',
                    hint: '+91 98765 43210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),

                  // Password
                  AppTextField(
                    label: 'Password',
                    hint: 'Minimum 6 characters',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Role dropdown
                  Text(
                    'Select Role',
                    style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: _selectedRole,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        items: _staffRoles.map((role) {
                          return DropdownMenuItem<UserRole>(
                            value: role,
                            child: Row(
                              children: [
                                Icon(_roleIcon(role), size: 20, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  role.displayName,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleCreateStaff,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.person_add_rounded, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Creating...' : 'Create Staff Account',
                        style: AppTextStyles.button.copyWith(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Staff List ────────────────────────────────────────────────────
            _SectionHeader(title: 'All Staff Members', icon: Icons.people_alt_outlined),
            const SizedBox(height: 14),
            _StaffListView(key: ValueKey(_listVersion)),
          ],
        ),
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return Icons.medical_services_outlined;
      case UserRole.receptionist:
        return Icons.support_agent_outlined;
      case UserRole.labTechnician:
        return Icons.science_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.badge_outlined;
    }
  }
}

// ── Staff list (reads directly from the mock DB) ──────────────────────────────

class _StaffListView extends StatelessWidget {
  const _StaffListView({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = MockUserDatabase.instance.staffMembers;
    if (staff.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No staff members yet.\nUse the form above to add one.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Email',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Role',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Table rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staff.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5, indent: 20),
            itemBuilder: (context, index) {
              final account = staff[index];
              return _StaffRow(
                name: account.name,
                email: account.email,
                role: account.role,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  final String name;
  final String email;
  final UserRole role;

  const _StaffRow({required this.name, required this.email, required this.role});

  Color _roleColor() {
    switch (role) {
      case UserRole.doctor:
        return const Color(0xFF6366F1);
      case UserRole.receptionist:
        return const Color(0xFF0EA5E9);
      case UserRole.labTechnician:
        return const Color(0xFF10B981);
      case UserRole.admin:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  radius: 18,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.body.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              email,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role.displayName,
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header helper ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
