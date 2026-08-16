import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/doctor.dart';
import '../../../models/test_booking.dart';
import '../../../services/shared_data_repository.dart';
import '../../../services/api_service.dart';
import '../../../utils/dummy_data.dart';
import '../../auth/auth_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String? initialDoctorId;
  final String? initialSlotTime;

  const BookAppointmentScreen({
    super.key,
    this.initialDoctorId,
    this.initialSlotTime,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _patientFormKey = GlobalKey<FormState>();

  int _currentStep = 1; // 1: Select Doctor, 2: Patient Info, 3: Date & Time, 4: Review

  // Step 1 State
  Doctor? _selectedDoctor;

  // Step 2 State (Patient Info)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Male';
  int? _calculatedAge;

  // Step 3 State (Appointment Date & Time Slots)
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _appointmentDateController = TextEditingController();
  String? _selectedSlotTime = '10:00 AM';

  static const List<Map<String, dynamic>> _mockSlots = [
    {'time': '09:00 AM', 'booked': 3, 'capacity': 10, 'status': 'Available'},
    {'time': '10:00 AM', 'booked': 8, 'capacity': 10, 'status': 'Available'},
    {'time': '11:00 AM', 'booked': 10, 'capacity': 10, 'status': 'FULL'},
    {'time': '02:00 PM', 'booked': 4, 'capacity': 10, 'status': 'Available'},
    {'time': '04:00 PM', 'booked': 9, 'capacity': 10, 'status': 'Available'},
    {'time': '05:30 PM', 'booked': 2, 'capacity': 10, 'status': 'Available'},
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      if (currentUser.mobile != null) {
        _phoneController.text = currentUser.mobile!;
      }
    }
    if (widget.initialDoctorId != null) {
      _selectedDoctor = mockDoctors.where((d) => d.id == widget.initialDoctorId).firstOrNull ?? mockDoctors.first;
    } else {
      _selectedDoctor = mockDoctors.first;
    }
    if (widget.initialSlotTime != null && widget.initialSlotTime!.isNotEmpty) {
      _selectedSlotTime = widget.initialSlotTime;
    }
    _appointmentDateController.text = _formatDateDDMMYYYY(_selectedDate);
    _dobController.addListener(_onDobChanged);
  }

  @override
  void dispose() {
    _dobController.removeListener(_onDobChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _appointmentDateController.dispose();
    super.dispose();
  }

  void _onDobChanged() {
    final text = _dobController.text.trim();
    if (text.length == 10) {
      try {
        final parts = text.split('-');
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

  String _formatDateDDMMYYYY(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d-$m-${date.year}';
  }

  Future<void> _pickDate({required bool isDob}) async {
    final initial = isDob ? DateTime(1997, 5, 12) : _selectedDate;
    final first = isDob ? DateTime(1920) : DateTime.now();
    final last = isDob ? DateTime.now() : DateTime.now().add(const Duration(days: 90));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      final formatted = _formatDateDDMMYYYY(picked);
      if (isDob) {
        _dobController.text = formatted;
      } else {
        setState(() {
          _selectedDate = picked;
          _appointmentDateController.text = formatted;
        });
      }
    }
  }

  Future<void> _submitFinalBooking() async {
    final doctor = _selectedDoctor!;
    final dateStr = _appointmentDateController.text.trim();
    final timeSlotStr = _selectedSlotTime ?? '10:00 AM';

    try {
      await ApiService.post('/appointments', {
        'doctorId': doctor.id,
        'date': dateStr,
        'timeSlot': timeSlotStr,
        'symptoms': 'Doctor Consultation',
      });
    } catch (_) {}

    final newBooking = TestBooking(
      testId: 'doc-${doctor.id}',
      testName: 'Doctor Consult: ${doctor.name} (${doctor.specialization})',
      category: 'Doctor Consultation',
      description: 'Consultation with ${doctor.qualification}, ${doctor.experience} exp.',
      sampleType: 'Consultation',
      price: double.tryParse(doctor.consultationFee.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 500.0,
      bookingId: 'ASTH-B-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      patientId: 'ASTH-P-000125',
      patientName: _nameController.text.trim(),
      appointmentDate: dateStr,
      appointmentTime: timeSlotStr,
      bookingStatus: 'CONFIRMED',
      sampleStatus: 'Consultation Pending',
      reportStatus: 'Consultation Notes Pending',
      currentStage: TestStage.bookingConfirmed,
    );

    ref.read(sharedDataProvider.notifier).addTestBooking(newBooking);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment successfully booked with ${doctor.name} at $timeSlotStr on $dateStr!',
          ),
          backgroundColor: const Color(0xFF00796B),
        ),
      );
      context.go('/patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Doctor Appointment',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step Indicator Header ─────────────────────────────────────────
            _StepHeaderDoc(currentStep: _currentStep),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepContent(),
              ),
            ),

            // ── Bottom Action Row ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Consultation Fee',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        _selectedDoctor?.consultationFee ?? '₹ 500',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00796B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _nextButtonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _nextButtonText {
    switch (_currentStep) {
      case 1:
        return 'Patient Info →';
      case 2:
        return 'Date & Time →';
      case 3:
        return 'Review Booking →';
      case 4:
        return 'Confirm Doctor Booking';
      default:
        return 'Continue';
    }
  }

  void _onNextPressed() {
    if (_currentStep == 1) {
      if (_selectedDoctor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a doctor to continue.')),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_patientFormKey.currentState!.validate()) {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      if (_selectedSlotTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an available time slot.')),
        );
        return;
      }
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      _submitFinalBooking();
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1DoctorSelection();
      case 2:
        return _buildStep2PatientInformation();
      case 3:
        return _buildStep3AppointmentDateTime();
      case 4:
        return _buildStep4ReviewBooking();
      default:
        return _buildStep1DoctorSelection();
    }
  }

  // ── STEP 1: Select Doctor ────────────────────────────────────────────────

  Widget _buildStep1DoctorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Select Doctor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose an expert specialist for your medical consultation.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockDoctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final doc = mockDoctors[i];
            final isSelected = _selectedDoctor?.id == doc.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedDoctor = doc),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8F7F5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: doc.localImagePath != null
                          ? Image.asset(doc.localImagePath!, width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: const Color(0xFF00796B).withValues(alpha: 0.1), child: const Icon(Icons.person, color: Color(0xFF00796B))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(doc.specialization, style: const TextStyle(fontSize: 12, color: Color(0xFF00796B), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${doc.qualification} • ${doc.experience}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(doc.consultationFee, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── STEP 2: Patient Information ──────────────────────────────────────────

  Widget _buildStep2PatientInformation() {
    return Form(
      key: _patientFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Patient Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the patient personal and contact information.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          Container(
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
                AppTextField(
                  label: 'Full Name *',
                  hint: 'Rahul Sharma',
                  controller: _nameController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Full Name is required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Phone Number *',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Phone Number is required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Email Address (Optional)',
                  hint: 'rahul.sharma@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Date of Birth (DOB) *',
                            hint: 'DD-MM-YYYY',
                            controller: _dobController,
                            keyboardType: TextInputType.datetime,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
                              onPressed: () => _pickDate(isDob: true),
                              tooltip: 'Open Calendar',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'DOB is required' : null,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 3: Appointment Date & Time ──────────────────────────────────────

  Widget _buildStep3AppointmentDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Appointment Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your appointment date and time slot (Max 10 per slot).',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        Container(
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
          child: AppTextField(
            label: 'Appointment Date *',
            hint: 'DD-MM-YYYY',
            controller: _appointmentDateController,
            keyboardType: TextInputType.datetime,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month, color: Color(0xFF00796B)),
              onPressed: () => _pickDate(isDob: false),
              tooltip: 'Open Calendar',
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Time Slot', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(10)),
              child: const Text('Max 10 per slot', style: TextStyle(color: Color(0xFF00796B), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: _mockSlots.length,
          itemBuilder: (context, i) {
            final slot = _mockSlots[i];
            final time = slot['time'] as String;
            final booked = slot['booked'] as int;
            final capacity = slot['capacity'] as int;
            final isFull = booked >= capacity;
            final isSelected = _selectedSlotTime == time;

            Color bgColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            Color textColor = AppColors.textPrimary;

            if (isFull) {
              bgColor = const Color(0xFFFFEBEE);
              borderColor = const Color(0xFFEF9A9A);
              textColor = const Color(0xFFD32F2F);
            } else if (isSelected) {
              bgColor = const Color(0xFF00796B);
              borderColor = const Color(0xFF00796B);
              textColor = Colors.white;
            } else if (booked >= 8) {
              bgColor = const Color(0xFFFFF8E1);
              borderColor = const Color(0xFFFFE082);
            }

            return GestureDetector(
              onTap: () {
                if (isFull) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This slot is FULL (10/10 booked). Please select another slot.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() => _selectedSlotTime = time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                        Text(isFull ? 'FULL' : 'Available', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : textColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$booked / $capacity booked', style: TextStyle(fontSize: 10.5, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LegendDotDoc(color: Color(0xFF2E7D32), label: 'Available'),
              _LegendDotDoc(color: Color(0xFF00796B), label: 'Selected'),
              _LegendDotDoc(color: Color(0xFFF57F17), label: 'Almost Full'),
              _LegendDotDoc(color: Color(0xFFD32F2F), label: 'FULL (10/10)'),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 4: Review & Submit ──────────────────────────────────────────────

  Widget _buildStep4ReviewBooking() {
    final doc = _selectedDoctor!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Review Appointment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please verify all information before confirming your doctor consultation.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECTED DOCTOR',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: doc.localImagePath != null
                        ? Image.asset(doc.localImagePath!, width: 50, height: 50, fit: BoxFit.cover)
                        : Container(width: 50, height: 50, color: const Color(0xFF00796B).withValues(alpha: 0.1), child: const Icon(Icons.person, color: Color(0xFF00796B))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(doc.specialization, style: const TextStyle(fontSize: 12, color: Color(0xFF00796B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text(doc.consultationFee, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                ],
              ),

              const Divider(height: 20),

              const Text(
                'PATIENT DETAILS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              _ReviewRowDoc(label: 'Name', value: _nameController.text.trim()),
              _ReviewRowDoc(label: 'Phone', value: _phoneController.text.trim()),
              _ReviewRowDoc(label: 'DOB / Age', value: '${_dobController.text.trim()} (${_calculatedAge ?? 28} Yrs)'),
              _ReviewRowDoc(label: 'Gender', value: _selectedGender),

              const Divider(height: 20),

              const Text(
                'APPOINTMENT SCHEDULE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              _ReviewRowDoc(label: 'Date', value: _appointmentDateController.text.trim()),
              _ReviewRowDoc(label: 'Time Slot', value: _selectedSlotTime ?? '10:00 AM'),
              _ReviewRowDoc(label: 'Location', value: doc.availability),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepHeaderDoc extends StatelessWidget {
  final int currentStep;

  const _StepHeaderDoc({required this.currentStep});

  static const _steps = ['Select Doctor', 'Patient Info', 'Date & Time', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final stepNum = i + 1;
          final isDone = stepNum < currentStep;
          final isCurrent = stepNum == currentStep;

          Color color = Colors.grey.shade400;
          if (isDone) color = const Color(0xFF2E7D32);
          if (isCurrent) color = const Color(0xFF00796B);

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: color,
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _steps[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? const Color(0xFF00796B) : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < _steps.length - 1)
                  Container(
                    width: 12,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LegendDotDoc extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDotDoc({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ReviewRowDoc extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRowDoc({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
