import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/test_booking.dart';
import '../providers/test_bookings_provider.dart';
import '../../../services/shared_data_repository.dart';
import '../../../services/api_service.dart';
import '../../auth/auth_provider.dart';

class DiagnosticTest {
  final String id;
  final String name;
  final double price;

  const DiagnosticTest({required this.id, required this.name, required this.price});
}

class BookTestScreen extends ConsumerStatefulWidget {
  final String? initialTestId;

  const BookTestScreen({super.key, this.initialTestId});

  @override
  ConsumerState<BookTestScreen> createState() => _BookTestScreenState();
}

class _BookTestScreenState extends ConsumerState<BookTestScreen> {
  final _patientFormKey = GlobalKey<FormState>();

  int _currentStep = 1; // 1: Select Test, 2: Patient Info, 3: Date & Time, 4: Review

  // Step 1 State
  final _searchController = TextEditingController();
  static const List<DiagnosticTest> _allTests = [
    DiagnosticTest(id: 't1', name: 'CBC (Complete Blood Count)', price: 399),
    DiagnosticTest(id: 't2', name: 'Lipid Profile', price: 699),
    DiagnosticTest(id: 't3', name: 'Thyroid Panel (T3, T4, TSH)', price: 499),
    DiagnosticTest(id: 't4', name: 'Sugar Test (Fasting & PP)', price: 299),
    DiagnosticTest(id: 't5', name: 'Vitamin D3 Test', price: 899),
    DiagnosticTest(id: 't6', name: 'Liver Function Test (LFT)', price: 699),
    DiagnosticTest(id: 't7', name: 'Kidney Function Test (KFT)', price: 599),
    DiagnosticTest(id: 't8', name: 'Urine Routine & Microscopy', price: 199),
  ];
  final Set<String> _selectedTestIds = {'t1'};
  String _searchQuery = '';

  // Step 2 State (Patient Details)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Male';
  int? _calculatedAge;

  // Step 3 State (Appointment Date & Time Slot)
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _appointmentDateController = TextEditingController();
  String? _selectedTimeSlot = '10:30 AM';
  bool _homeCollection = false;

  static const List<Map<String, dynamic>> _mockSlots = [
    {'time': '08:30 AM', 'booked': 3, 'capacity': 10, 'status': 'Available'},
    {'time': '09:30 AM', 'booked': 7, 'capacity': 10, 'status': 'Available'},
    {'time': '10:30 AM', 'booked': 8, 'capacity': 10, 'status': 'Available'},
    {'time': '11:30 AM', 'booked': 10, 'capacity': 10, 'status': 'FULL'},
    {'time': '02:00 PM', 'booked': 4, 'capacity': 10, 'status': 'Available'},
    {'time': '04:30 PM', 'booked': 9, 'capacity': 10, 'status': 'Available'},
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
    if (widget.initialTestId != null && widget.initialTestId!.isNotEmpty) {
      _selectedTestIds.clear();
      _selectedTestIds.add(widget.initialTestId!);
    }
    _appointmentDateController.text = _formatDateDDMMYYYY(_selectedDate);
    _dobController.addListener(_onDobChanged);
  }

  @override
  void dispose() {
    _dobController.removeListener(_onDobChanged);
    _searchController.dispose();
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

  double get _totalPrice {
    double testsSum = _allTests
        .where((t) => _selectedTestIds.contains(t.id))
        .fold(0.0, (sum, t) => sum + t.price);
    if (_homeCollection) {
      testsSum += 100.0;
    }
    return testsSum;
  }

  Future<void> _submitFinalBooking() async {
    final selectedTests = _allTests.where((t) => _selectedTestIds.contains(t.id)).toList();
    final primaryTest = selectedTests.first;

    final appointmentDate = _appointmentDateController.text.trim();
    final timeSlot = _selectedTimeSlot ?? '10:30 AM';
    final user = ref.read(authProvider).user;
    final patientName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (user?.name ?? 'Patient');

    Map<String, dynamic>? apiResult;
    try {
      final res = await ApiService.post('/bookings', {
        'testId': primaryTest.id,
        'appointmentDate': appointmentDate,
        'timeSlot': timeSlot,
        'price': _totalPrice,
      });
      if (res['success'] == true) {
        apiResult = (res['data'] is Map) ? res['data'] as Map<String, dynamic> : null;
      } else if (res['message'] != null && !res['message'].toString().contains('Network error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'].toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } catch (_) {}

    final bookingId = (apiResult != null && (apiResult['bookingId'] != null || apiResult['id'] != null))
        ? (apiResult['bookingId'] ?? apiResult['id']).toString()
        : 'ASTH-B-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newBooking = TestBooking(
      testId: primaryTest.id,
      testName: selectedTests.length > 1
          ? '${primaryTest.name} (+${selectedTests.length - 1} more)'
          : primaryTest.name,
      category: 'Blood Tests',
      description: 'Scheduled laboratory test booking.',
      sampleType: 'Blood / Sample',
      price: _totalPrice,
      bookingId: bookingId,
      patientId: 'ASTH-P-000125',
      patientName: patientName,
      appointmentDate: appointmentDate,
      appointmentTime: timeSlot,
      bookingStatus: 'CONFIRMED',
      sampleStatus: 'Sample Collection Pending',
      reportStatus: 'Awaiting Sample Collection',
      currentStage: TestStage.bookingConfirmed,
    );

    ref.read(testBookingsProvider.notifier).addBooking(newBooking);
    ref.read(sharedDataProvider.notifier).addTestBooking(newBooking);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking Confirmed ($bookingId)! Test added to My Tests. Total: ₹${_totalPrice.toInt()}',
          ),
          backgroundColor: const Color(0xFF00796B),
        ),
      );
      context.go('/public/my-tests');
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
          'Book Lab Test',
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
            _StepHeader(currentStep: _currentStep),

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
                        'Total Price',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        '₹${_totalPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
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
        return 'Confirm Booking';
      default:
        return 'Continue';
    }
  }

  void _onNextPressed() {
    if (_currentStep == 1) {
      if (_selectedTestIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one test.')),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_patientFormKey.currentState!.validate()) {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      if (_selectedTimeSlot == null) {
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
        return _buildStep1TestSelection();
      case 2:
        return _buildStep2PatientInformation();
      case 3:
        return _buildStep3AppointmentDateTime();
      case 4:
        return _buildStep4ReviewBooking();
      default:
        return _buildStep1TestSelection();
    }
  }

  // ── STEP 1: Select Test ──────────────────────────────────────────────────

  Widget _buildStep1TestSelection() {
    final filteredTests = _allTests
        .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Select Diagnostic Tests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose the required tests for your diagnostic evaluation.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Search tests (e.g. CBC, Thyroid, LFT)',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Color(0xFF00796B)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredTests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final test = filteredTests[index];
            final selected = _selectedTestIds.contains(test.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    if (_selectedTestIds.length > 1) {
                      _selectedTestIds.remove(test.id);
                    }
                  } else {
                    _selectedTestIds.add(test.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFE0F2F1) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? const Color(0xFF00796B) : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected,
                      activeColor: const Color(0xFF00796B),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedTestIds.add(test.id);
                          } else if (_selectedTestIds.length > 1) {
                            _selectedTestIds.remove(test.id);
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        test.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${test.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
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
            'Enter the personal details of the patient undergoing the test.',
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
                    // DOB Field
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
                    // Gender Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gender',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
          'Select your preferred date and available 10-patient capacity slot.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Date Selection Box
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
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Time Slot',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Max 10 per slot',
                style: TextStyle(color: Color(0xFF00796B), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Time Slot Grid (Capacity 10 per slot)
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
            final isSelected = _selectedTimeSlot == time;

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
                setState(() => _selectedTimeSlot = time);
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
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          isFull ? 'FULL' : 'Available',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$booked / $capacity booked',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isSelected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Slot Legend
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LegendDot(color: Color(0xFF2E7D32), label: 'Available'),
              _LegendDot(color: Color(0xFF00796B), label: 'Selected'),
              _LegendDot(color: Color(0xFFF57F17), label: 'Almost Full'),
              _LegendDot(color: Color(0xFFD32F2F), label: 'FULL (10/10)'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Home Sample Collection Option
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            value: _homeCollection,
            onChanged: (v) => setState(() => _homeCollection = v),
            activeThumbColor: const Color(0xFF00796B),
            title: const Text(
              'Home Sample Collection',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Convenience fee ₹100 applicable',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 4: Review & Submit ──────────────────────────────────────────────

  Widget _buildStep4ReviewBooking() {
    final selectedTests = _allTests.where((t) => _selectedTestIds.contains(t.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Review Booking Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please verify all information before confirming your test booking.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Summary Card
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
                'SELECTED TESTS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ...selectedTests.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('₹${t.price.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              if (_homeCollection) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Home Collection Fee', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('₹100', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              const Divider(height: 20),

              const Text(
                'PATIENT DETAILS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              _ReviewRow(label: 'Name', value: _nameController.text.trim()),
              _ReviewRow(label: 'Phone', value: _phoneController.text.trim()),
              _ReviewRow(label: 'DOB / Age', value: '${_dobController.text.trim()} (${_calculatedAge ?? 28} Yrs)'),
              _ReviewRow(label: 'Gender', value: _selectedGender),

              const Divider(height: 20),

              const Text(
                'APPOINTMENT SCHEDULE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B), letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              _ReviewRow(label: 'Date', value: _appointmentDateController.text.trim()),
              _ReviewRow(label: 'Time Slot', value: _selectedTimeSlot ?? '10:30 AM'),
              _ReviewRow(label: 'Location', value: 'Astha Diagnostic Center Main Lab'),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helper Sub-Widgets ────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int currentStep;

  const _StepHeader({required this.currentStep});

  static const _steps = ['Select Test', 'Patient Info', 'Date & Time', 'Review'];

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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

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
