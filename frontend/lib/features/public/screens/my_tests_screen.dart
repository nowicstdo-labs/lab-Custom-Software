import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/test_booking.dart';
import '../providers/test_bookings_provider.dart';
import '../../../services/shared_data_repository.dart';

class MyTestsScreen extends ConsumerStatefulWidget {
  const MyTestsScreen({super.key});

  @override
  ConsumerState<MyTestsScreen> createState() => _MyTestsScreenState();
}

class _MyTestsScreenState extends ConsumerState<MyTestsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _bottomNavIndex = 1; // My Tests tab is index 1

  static const _filterOptions = [
    'All',
    'Upcoming',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  List<TestBooking> _getFilteredBookings(List<TestBooking> allBookings) {
    return allBookings.where((booking) {
      // Search query match
      final matchesSearch = _searchQuery.isEmpty ||
          booking.testName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.bookingId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.testId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          booking.category.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter chip match
      bool matchesFilter = true;
      if (_selectedFilter == 'Upcoming') {
        matchesFilter = booking.isUpcoming;
      } else if (_selectedFilter == 'In Progress') {
        matchesFilter = booking.isInProgress;
      } else if (_selectedFilter == 'Completed') {
        matchesFilter = booking.isCompleted;
      } else if (_selectedFilter == 'Cancelled') {
        matchesFilter = booking.isCancelled;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final testBookingsList = ref.watch(testBookingsProvider);
    final sharedData = ref.watch(sharedDataProvider);
    final allBookings = [
      ...sharedData.bookings,
      ...testBookingsList.where((tb) => !sharedData.bookings.any((b) => b.bookingId == tb.bookingId)),
    ];
    final filteredBookings = _getFilteredBookings(allBookings);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'My Tests',
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
                onPressed: () => context.push('/notification-center'),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // ── Search Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search your tests...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Filter Chips ──────────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = _filterOptions[i];
                final selected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF00796B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00796B).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // ── Test Cards List / Empty State ────────────────────────────────
          Expanded(
            child: filteredBookings.isEmpty
                ? _EmptyTestsState(
                    onBookTest: () => context.push('/public/tests'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final booking = filteredBookings[i];
                      return _MyTestCard(
                        booking: booking,
                        onViewDetails: () {
                          _showTestDetailsModal(context, booking);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── Bottom Navigation (4 Items: Home, My Tests, Reports, Profile) ─────
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            if (index == 0) {
              context.go('/patient');
            } else if (index == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Reports viewer...')),
              );
            } else if (index == 3) {
              context.push('/public/profile');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00796B),
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.biotech_rounded),
              label: 'My Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _showTestDetailsModal(BuildContext context, TestBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TestDetailsSheet(booking: booking),
    );
  }
}

// ── Test Card Component ───────────────────────────────────────────────────────

class _MyTestCard extends StatelessWidget {
  final TestBooking booking;
  final VoidCallback onViewDetails;

  const _MyTestCard({
    required this.booking,
    required this.onViewDetails,
  });

  Color get _statusColor {
    switch (booking.currentStage) {
      case TestStage.bookingConfirmed:
        return const Color(0xFF2E7D32); // Green
      case TestStage.samplePending:
        return const Color(0xFFF57F17); // Yellow
      case TestStage.sampleCollected:
      case TestStage.processing:
        return const Color(0xFF1565C0); // Blue
      case TestStage.reportReady:
        return const Color(0xFF00796B); // Teal
      case TestStage.completed:
        return const Color(0xFF37474F); // Dark Grey / Black
      case TestStage.cancelled:
        return const Color(0xFFD32F2F); // Red
    }
  }

  Color get _statusBgColor {
    switch (booking.currentStage) {
      case TestStage.bookingConfirmed:
        return const Color(0xFFE8F5E9);
      case TestStage.samplePending:
        return const Color(0xFFFFF8E1);
      case TestStage.sampleCollected:
      case TestStage.processing:
        return const Color(0xFFE3F2FD);
      case TestStage.reportReady:
        return const Color(0xFFE0F2F1);
      case TestStage.completed:
        return const Color(0xFFECEFF1);
      case TestStage.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  String get _statusLabelText {
    switch (booking.currentStage) {
      case TestStage.bookingConfirmed:
        return '🟢 Confirmed';
      case TestStage.samplePending:
        return '🟡 Sample Pending';
      case TestStage.sampleCollected:
        return '🔵 Sample Collected';
      case TestStage.processing:
        return '🔵 Processing';
      case TestStage.reportReady:
        return '🟢 Report Ready';
      case TestStage.completed:
        return '⚫ Completed';
      case TestStage.cancelled:
        return '🔴 Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          // Top Row: Icon + Name & Desc + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.water_drop_rounded, color: Color(0xFF00796B), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.testName,
                      style: AppTextStyles.headline3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      booking.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabelText,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date & Time + Price Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF00796B)),
                    const SizedBox(width: 5),
                    Text(
                      booking.appointmentDate,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF00796B)),
                    const SizedBox(width: 5),
                    Text(
                      booking.appointmentTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${booking.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00796B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // IDs Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking ID: ${booking.bookingId}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Patient ID: ${booking.patientId}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Progress Journey Tracker ─────────────────────────────────────
          _TestProgressTracker(currentStage: booking.currentStage),

          const SizedBox(height: 14),

          // ── Action Buttons ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onViewDetails,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00796B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (booking.isReportAvailable) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/pdf-report?reportId=ASTH-RPT-2026-00120');
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 14),
                  label: const Text(
                    'View Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Journey / Progress Tracker Stepper ───────────────────────────────────────

class _TestProgressTracker extends StatelessWidget {
  final TestStage currentStage;

  const _TestProgressTracker({required this.currentStage});

  int get _stageIndex {
    switch (currentStage) {
      case TestStage.bookingConfirmed:
        return 0;
      case TestStage.samplePending:
        return 1;
      case TestStage.sampleCollected:
        return 2;
      case TestStage.processing:
        return 3;
      case TestStage.reportReady:
        return 4;
      case TestStage.completed:
        return 5;
      case TestStage.cancelled:
        return -1;
    }
  }

  static const _stages = [
    'Confirmed',
    'Sample',
    'Collected',
    'Processing',
    'Report Ready',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStage == TestStage.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text(
              'Test Booking Cancelled',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _stageIndex;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stages.length, (i) {
              final isDone = i < currentIndex;
              final isCurrent = i == currentIndex;

              Color dotColor = Colors.grey.shade400;
              if (isDone) dotColor = const Color(0xFF2E7D32);
              if (isCurrent) dotColor = const Color(0xFF00796B);

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    if (i < _stages.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentIndex
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stages.length, (i) {
              final isCurrent = i == currentIndex;
              return Expanded(
                child: Text(
                  _stages[i],
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? const Color(0xFF00796B) : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyTestsState extends StatelessWidget {
  final VoidCallback onBookTest;

  const _EmptyTestsState({required this.onBookTest});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00796B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.biotech, size: 64, color: Color(0xFF00796B)),
            ),
            const SizedBox(height: 20),
            Text(
              'No Tests Yet',
              style: AppTextStyles.headline3.copyWith(
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booked tests will appear here.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBookTest,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Book a Test',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Test Details Bottom Sheet Modal ──────────────────────────────────────────

class _TestDetailsSheet extends StatelessWidget {
  final TestBooking booking;

  const _TestDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Test Details',
                  style: AppTextStyles.headline3.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Section 1: TEST INFORMATION ───────────────────────────────
            _DetailsSectionHeader(title: 'TEST INFORMATION', icon: Icons.biotech_outlined),
            const SizedBox(height: 8),
            _DetailTile(label: 'Test Name', value: booking.testName),
            _DetailTile(label: 'Test ID', value: booking.testId),
            _DetailTile(label: 'Category', value: booking.category),
            _DetailTile(label: 'Sample Type', value: booking.sampleType),
            _DetailTile(label: 'Test Price', value: '₹${booking.price.toInt()}'),
            _DetailTile(label: 'Booking ID', value: booking.bookingId),
            _DetailTile(label: 'Patient ID', value: '${booking.patientId} (${booking.patientName})'),

            const SizedBox(height: 20),

            // ── Section 2: APPOINTMENT INFORMATION ────────────────────────
            _DetailsSectionHeader(title: 'APPOINTMENT INFORMATION', icon: Icons.calendar_month_outlined),
            const SizedBox(height: 8),
            _DetailTile(label: 'Appointment Date', value: booking.appointmentDate),
            _DetailTile(label: 'Appointment Time', value: booking.appointmentTime),
            _DetailTile(label: 'Booking Status', value: booking.bookingStatus),

            const SizedBox(height: 20),

            // ── Section 3: SAMPLE INFORMATION ─────────────────────────────
            _DetailsSectionHeader(title: 'SAMPLE INFORMATION', icon: Icons.science_outlined),
            const SizedBox(height: 8),
            _DetailTile(label: 'Sample Status', value: booking.sampleStatus),
            _DetailTile(
              label: 'Sample Collection Date',
              value: booking.sampleCollectionDate ?? 'Not yet collected',
            ),
            _DetailTile(
              label: 'Sample Collection Time',
              value: booking.sampleCollectionTime ?? 'Pending',
            ),

            const SizedBox(height: 20),

            // ── Section 4: REPORT INFORMATION ─────────────────────────────
            _DetailsSectionHeader(title: 'REPORT INFORMATION', icon: Icons.description_outlined),
            const SizedBox(height: 8),
            _DetailTile(label: 'Report Status', value: booking.reportStatus),
            _DetailTile(
              label: 'Report Date',
              value: booking.reportDate ?? 'Report expected soon',
            ),

            const SizedBox(height: 24),

            // Report Actions if available
            if (booking.isReportAvailable) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening report for ${booking.testName}...')),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF00796B)),
                      label: const Text('View Report', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00796B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading PDF for ${booking.testName}...')),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.white),
                      label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DetailsSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00796B), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00796B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
