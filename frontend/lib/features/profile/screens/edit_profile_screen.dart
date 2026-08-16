import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/image_picker_dialog.dart';
import '../../../services/api_service.dart';
import '../providers/patient_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  String _selectedRelationship = 'Father';
  int? _calculatedAge;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(patientProfileProvider);

    _nameController = TextEditingController(text: profile.fullName);
    _dobController = TextEditingController(text: profile.dob);
    _phoneController = TextEditingController(text: profile.phone);
    _emailController = TextEditingController(text: profile.email);
    _alternatePhoneController = TextEditingController(text: profile.alternateNumber);
    _addressController = TextEditingController(text: profile.address);
    _emergencyNameController = TextEditingController(text: profile.emergencyName);
    _emergencyPhoneController = TextEditingController(text: profile.emergencyPhone);

    _selectedGender = profile.gender;
    _selectedBloodGroup = profile.bloodGroup;
    _selectedRelationship = profile.emergencyRelationship;

    _dobController.addListener(_onDobChanged);
    _calculateAgeFromDob(profile.dob);
  }

  @override
  void dispose() {
    _dobController.removeListener(_onDobChanged);
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _alternatePhoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _onDobChanged() {
    _calculateAgeFromDob(_dobController.text.trim());
  }

  void _calculateAgeFromDob(String dobStr) {
    if (dobStr.length == 10) {
      try {
        final parts = dobStr.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final dob = DateTime(year, month, day);
          final now = DateTime.now();
          int age = now.year - dob.year;
          if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
            age--;
          }
          if (age >= 0 && age <= 120) {
            setState(() => _calculatedAge = age);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _pickDobDate() async {
    DateTime initialDate = DateTime(1997, 5, 12);
    try {
      final parts = _dobController.text.trim().split('-');
      if (parts.length == 3) {
        initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      _dobController.text = formatted;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final current = ref.read(patientProfileProvider);
      final updated = current.copyWith(
        fullName: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        alternateNumber: _alternatePhoneController.text.trim(),
        address: _addressController.text.trim(),
        emergencyName: _emergencyNameController.text.trim(),
        emergencyRelationship: _selectedRelationship,
        emergencyPhone: _emergencyPhoneController.text.trim(),
      );

      try {
        await ApiService.patch('/patients/me', {
          'dob': _dobController.text.trim(),
          'gender': _selectedGender,
          'bloodGroup': _selectedBloodGroup,
          'address': _addressController.text.trim(),
          'alternateNumber': _alternatePhoneController.text.trim(),
          'emergencyName': _emergencyNameController.text.trim(),
          'emergencyPhone': _emergencyPhoneController.text.trim(),
        });
      } catch (_) {}

      ref.read(patientProfileProvider.notifier).updateProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF00796B),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Camera Trigger Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(
                            _nameController.text.isNotEmpty ? _nameController.text.substring(0, 1) : 'P',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF14B8A6),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              onPressed: () {
                                ImagePickerDialog.show(
                                  context,
                                  title: 'Change Profile Photo',
                                  onImageSelected: (path) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Profile photo updated: $path')),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        ImagePickerDialog.show(
                          context,
                          title: 'Change Profile Photo',
                          onImageSelected: (path) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Profile photo updated: $path')),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── PERSONAL INFORMATION ─────────────────────────────────────
              _FormSectionCard(
                title: 'Personal Information',
                children: [
                  AppTextField(
                    label: 'Full Name *',
                    hint: 'Rahul Kumar',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Date of Birth
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Date of Birth *',
                              hint: 'DD-MM-YYYY',
                              controller: _dobController,
                              keyboardType: TextInputType.datetime,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
                                onPressed: _pickDobDate,
                                tooltip: 'Open Calendar',
                              ),
                            ),
                            if (_calculatedAge != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Age: $_calculatedAge Years',
                                style: const TextStyle(
                                  color: Color(0xFF00796B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Gender Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender',
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedGender,
                                  isExpanded: true,
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedGender = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Blood Group Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blood Group',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBloodGroup,
                            isExpanded: true,
                            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                                .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedBloodGroup = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── CONTACT INFORMATION ──────────────────────────────────────
              _FormSectionCard(
                title: 'Contact Information',
                children: [
                  AppTextField(
                    label: 'Phone Number *',
                    hint: '+91 98765 43210',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Email',
                    hint: 'rahulkumar@gmail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Alternate Number',
                    hint: '+91 91234 56789',
                    controller: _alternatePhoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── ADDRESS INFORMATION ──────────────────────────────────────
              _FormSectionCard(
                title: 'Address Information',
                children: [
                  AppTextField(
                    label: 'Address',
                    hint: 'Enter full address...',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── EMERGENCY CONTACT (OPTIONAL) ─────────────────────────────
              _FormSectionCard(
                title: 'Emergency Contact (Optional)',
                children: [
                  AppTextField(
                    label: 'Contact Name',
                    hint: 'Suresh Kumar',
                    controller: _emergencyNameController,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Relationship',
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedRelationship,
                                  isExpanded: true,
                                  items: ['Father', 'Mother', 'Spouse', 'Sibling', 'Other']
                                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedRelationship = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Phone Number',
                          hint: '+91 98765 00000',
                          controller: _emergencyPhoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FormSectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headline3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
