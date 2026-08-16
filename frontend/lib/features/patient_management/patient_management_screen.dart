import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../features/auth/auth_models.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/dashboard/widgets/dashboard_scaffold.dart';
import '../../models/patient_record.dart';
import 'patient_management_provider.dart';

class PatientManagementScreen extends ConsumerStatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  ConsumerState<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends ConsumerState<PatientManagementScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _genderController = TextEditingController(text: 'Female');
  final _dobController = TextEditingController(text: '1990-01-01');
  final _bloodGroupController = TextEditingController(text: 'O+');
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _historyController = TextEditingController(text: 'No major conditions noted.');
  final _allergiesController = TextEditingController(text: 'None reported.');
  final _medicationController = TextEditingController(text: 'None');
  final _doctorController = TextEditingController();

  bool _isRegistering = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    _historyController.dispose();
    _allergiesController.dispose();
    _medicationController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  Future<void> _searchPatient() async {
    await ref.read(patientManagementProvider.notifier).searchPatients(_searchController.text);
  }

  Future<void> _registerPatient() async {
    setState(() => _isRegistering = true);
    try {
      await ref.read(patientManagementProvider.notifier).registerPatient(
        fullName: _nameController.text.trim(),
        gender: _genderController.text.trim(),
        dateOfBirth: DateTime.tryParse(_dobController.text) ?? DateTime(1990),
        bloodGroup: _bloodGroupController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        emergencyContact: _emergencyController.text.trim(),
        medicalHistory: _historyController.text.trim(),
        allergies: _allergiesController.text.trim(),
        currentMedications: _medicationController.text.trim(),
        referringDoctor: _doctorController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient record processed.')));
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientManagementProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user?.role == UserRole.receptionist;

    return DashboardScaffold(
      title: 'Patient Identification',
      currentRoute: '/patients',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('Patient Identification System', style: AppTextStyles.headline2),
            const SizedBox(height: 10),
            Text('Search by patient ID, mobile number, full name or Aadhaar to prevent duplicates and access complete history.', style: AppTextStyles.subtitle),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(label: 'Search patient', hint: 'Try AD-2026-000001 or mobile', controller: _searchController),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(onPressed: _searchPatient, icon: const Icon(Icons.search), label: const Text('Search')),
              ],
            ),
            const SizedBox(height: 18),
            if (state.message != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                child: Text(state.message!, style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 24),
            if (state.selectedPatient != null) ...[
              _PatientProfileCard(patient: state.selectedPatient!),
              const SizedBox(height: 24),
            ],
            if (canEdit) ...[
              Text('Register / update patient', style: AppTextStyles.headline3),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 16, runSpacing: 16, children: [
                      SizedBox(width: 280, child: AppTextField(label: 'Full name', hint: 'Enter full name', controller: _nameController)),
                      SizedBox(width: 220, child: AppTextField(label: 'Mobile number', hint: '+91...', controller: _mobileController, keyboardType: TextInputType.phone)),
                      SizedBox(width: 220, child: AppTextField(label: 'Aadhaar number', hint: 'Optional', controller: _aadhaarController)),
                      SizedBox(width: 180, child: AppTextField(label: 'Gender', hint: 'Female', controller: _genderController)),
                      SizedBox(width: 180, child: AppTextField(label: 'DOB', hint: 'YYYY-MM-DD', controller: _dobController)),
                      SizedBox(width: 180, child: AppTextField(label: 'Blood group', hint: 'O+', controller: _bloodGroupController)),
                      SizedBox(width: 320, child: AppTextField(label: 'Address', hint: 'Complete address', controller: _addressController)),
                      SizedBox(width: 280, child: AppTextField(label: 'Email', hint: 'name@example.com', controller: _emailController, keyboardType: TextInputType.emailAddress)),
                      SizedBox(width: 240, child: AppTextField(label: 'Emergency contact', hint: 'Optional', controller: _emergencyController)),
                      SizedBox(width: 280, child: AppTextField(label: 'Medical history', hint: 'Past conditions', controller: _historyController)),
                      SizedBox(width: 260, child: AppTextField(label: 'Allergies', hint: 'Penicillin', controller: _allergiesController)),
                      SizedBox(width: 260, child: AppTextField(label: 'Current medications', hint: 'Metformin', controller: _medicationController)),
                      SizedBox(width: 280, child: AppTextField(label: 'Referring doctor', hint: 'Optional', controller: _doctorController)),
                    ]),
                    const SizedBox(height: 18),
                    FilledButton.icon(onPressed: _isRegistering ? null : _registerPatient, icon: const Icon(Icons.person_add), label: Text(_isRegistering ? 'Registering...' : 'Register patient')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatientProfileCard extends StatelessWidget {
  final PatientRecord patient;

  const _PatientProfileCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.fullName, style: AppTextStyles.headline3.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text('Patient ID: ${patient.patientId}', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)), child: Text('Returning patient', style: AppTextStyles.body.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 18),
        Wrap(spacing: 16, runSpacing: 16, children: [
          _InfoTile(label: 'Registration', value: '${patient.registrationDate.day}/${patient.registrationDate.month}/${patient.registrationDate.year}'),
          _InfoTile(label: 'Gender', value: patient.gender),
          _InfoTile(label: 'DOB', value: '${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}'),
          _InfoTile(label: 'Age', value: '${patient.age}'),
          _InfoTile(label: 'Blood Group', value: patient.bloodGroup),
          _InfoTile(label: 'Mobile', value: patient.mobileNumber),
          _InfoTile(label: 'Email', value: patient.email ?? 'N/A'),
          _InfoTile(label: 'Address', value: patient.address),
        ]),
        const SizedBox(height: 24),
        Text('Medical profile', style: AppTextStyles.headline3),
        const SizedBox(height: 10),
        Text('Medical history: ${patient.medicalHistory}', style: AppTextStyles.body),
        const SizedBox(height: 6),
        Text('Allergies: ${patient.allergies}', style: AppTextStyles.body),
        const SizedBox(height: 6),
        Text('Current medications: ${patient.currentMedications}', style: AppTextStyles.body),
        const SizedBox(height: 6),
        Text('Referring doctor: ${patient.referringDoctor ?? 'Not assigned'}', style: AppTextStyles.body),
        const SizedBox(height: 24),
        Text('Patient timeline', style: AppTextStyles.headline3),
        const SizedBox(height: 10),
        ...patient.timeline.map((entry) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)), child: Row(children: [
          Icon(Icons.timeline, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(entry.description, style: AppTextStyles.body),
          ])),
          Text('${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
        ]))),
        const SizedBox(height: 20),
        Text('Quick actions', style: AppTextStyles.headline3),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _ActionChip(icon: Icons.calendar_month, label: 'Book new test'),
          _ActionChip(icon: Icons.home, label: 'Home collection'),
          _ActionChip(icon: Icons.download, label: 'Download reports'),
          _ActionChip(icon: Icons.history, label: 'View history'),
          _ActionChip(icon: Icons.print, label: 'Print card'),
          _ActionChip(icon: Icons.share, label: 'Share ID'),
        ]),
        const SizedBox(height: 20),
        Text('Previous records', style: AppTextStyles.headline3),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _RecordPill(label: 'Appointments', value: patient.previousAppointments.join(' • ')),
          _RecordPill(label: 'Reports', value: patient.previousReports.join(' • ')),
          _RecordPill(label: 'Prescriptions', value: patient.previousPrescriptions.join(' • ')),
          _RecordPill(label: 'Payments', value: patient.previousPayments.join(' • ')),
        ]),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: AppColors.primary),
      label: Text(label),
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
    );
  }
}

class _RecordPill extends StatelessWidget {
  final String label;
  final String value;

  const _RecordPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.body),
      ]),
    );
  }
}
