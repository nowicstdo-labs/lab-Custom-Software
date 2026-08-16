import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/image_picker_dialog.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/shared_data_repository.dart';

class MedicineEntry {
  String name = '';
  String dosage = '';
  String duration = '';
}

class ConsultationScreen extends ConsumerStatefulWidget {
  final String patientName;

  const ConsultationScreen({super.key, required this.patientName});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _weightController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();

  final Map<String, bool> _recommendedTests = {
    'CBC': false,
    'Lipid Profile': false,
    'Sugar Test': false,
    'Thyroid Panel': false,
  };

  final List<MedicineEntry> _medicines = [MedicineEntry()];

  @override
  void dispose() {
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _weightController.dispose();
    _symptomsController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  void _addMedicine() {
    setState(() {
      _medicines.add(MedicineEntry());
    });
  }

  void _removeMedicine(int index) {
    if (_medicines.length > 1) {
      setState(() {
        _medicines.removeAt(index);
      });
    }
  }

  void _saveConsultation() {
    if (_formKey.currentState!.validate()) {
      _recommendedTests.forEach((testName, isChecked) {
        if (isChecked) {
          ref.read(sharedDataProvider.notifier).addDoctorRecommendation(
                patientId: 'ASTH-P-000125',
                testName: testName,
                doctorName: 'Dr. Priya Mehta',
              );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation saved! Diagnostic test recommendations sent to patient account.'),
          backgroundColor: Color(0xFF00796B),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: isMultiline ? 4 : 1,
          style: AppTextStyles.body.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: isDark ? const Color(0xFF17203E) : const Color(0xFFF4F7FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName, style: AppTextStyles.headline3.copyWith(color: isDark ? Colors.white : AppColors.textPrimary)),
        backgroundColor: isDark ? const Color(0xFF141B2D) : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.primary),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Consultation', style: AppTextStyles.headline2),
                const SizedBox(height: 6),
                Text('Record patient vitals, symptoms, diagnosis, and prescription details.', style: AppTextStyles.subtitle),
                const SizedBox(height: 24),
                
                // Vitals Section
                Text('Patient Vitals', style: AppTextStyles.headline3),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: [
                    _buildTextField(
                      label: 'Blood Pressure',
                      hint: '120/80',
                      controller: _bpController,
                      suffix: 'mmHg',
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      label: 'Pulse Rate',
                      hint: '72',
                      controller: _pulseController,
                      suffix: 'bpm',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      label: 'Temperature',
                      hint: '98.6',
                      controller: _tempController,
                      suffix: '°F',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      label: 'Weight',
                      hint: '70',
                      controller: _weightController,
                      suffix: 'kg',
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Symptoms & Diagnosis Section
                _buildTextField(
                  label: 'Symptoms',
                  hint: 'Enter patient reported symptoms...',
                  controller: _symptomsController,
                  isMultiline: true,
                  validator: (v) => v == null || v.isEmpty ? 'Symptoms required' : null,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  label: 'Diagnosis / Clinical Impression',
                  hint: 'Enter your assessment...',
                  controller: _diagnosisController,
                  isMultiline: true,
                  validator: (v) => v == null || v.isEmpty ? 'Diagnosis required' : null,
                ),
                const SizedBox(height: 24),

                // Recommended Tests Section
                Text('Recommend Lab Tests', style: AppTextStyles.headline3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: _recommendedTests.keys.map((test) {
                    final selected = _recommendedTests[test]!;
                    return FilterChip(
                      label: Text(test, style: AppTextStyles.body.copyWith(color: selected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary))),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      backgroundColor: isDark ? const Color(0xFF17203E) : const Color(0xFFF4F7FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.transparent)),
                      onSelected: (val) {
                        setState(() {
                          _recommendedTests[test] = val;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Medical Attachment / Camera Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Medical Attachments', style: AppTextStyles.headline3),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Attach Document / Photo'),
                      onPressed: () {
                        ImagePickerDialog.show(
                          context,
                          title: 'Attach Clinical Document',
                          onImageSelected: (path) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Attached document: $path')),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Prescription Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prescription', style: AppTextStyles.headline3),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Medicine'),
                      onPressed: _addMedicine,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medicines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = _medicines[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF17203E) : const Color(0xFFF4F7FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Medicine #${index + 1}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              if (_medicines.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _removeMedicine(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: entry.name,
                            style: AppTextStyles.body.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Medicine Name',
                              labelStyle: AppTextStyles.subtitle,
                              hintText: 'e.g. Paracetamol 650mg',
                              filled: true,
                              fillColor: isDark ? const Color(0xFF101820) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            onChanged: (v) => entry.name = v,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: entry.dosage,
                                  style: AppTextStyles.body.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    labelText: 'Dosage',
                                    labelStyle: AppTextStyles.subtitle,
                                    hintText: 'e.g. 1-0-1 (after food)',
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF101820) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  onChanged: (v) => entry.dosage = v,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: entry.duration,
                                  style: AppTextStyles.body.copyWith(color: isDark ? Colors.white : AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    labelText: 'Duration (days)',
                                    labelStyle: AppTextStyles.subtitle,
                                    hintText: 'e.g. 5',
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF101820) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  onChanged: (v) => entry.duration = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Save button
                PrimaryButton(
                  label: 'Save & Complete Consultation',
                  onPressed: _saveConsultation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
