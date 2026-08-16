import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/appointment.dart';
import '../../../utils/dummy_data.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 1; // Appointments tab active
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointments({required bool isUpcoming}) {
    return demoAppointments.where((apt) {
      final matchesTab = apt.isUpcoming == isUpcoming;
      final matchesFilter = _selectedStatusFilter == 'All' ||
          apt.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
      return matchesTab && matchesFilter;
    }).toList();
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
          'Appointments',
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
                onPressed: () {},
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00796B),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00796B),
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.headline3.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past Appointments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Upcoming Tab Content ──────────────────────────────────────────
          _AppointmentTabContent(
            appointments: _getAppointments(isUpcoming: true),
            selectedFilter: _selectedStatusFilter,
            onFilterChanged: (filter) => setState(() => _selectedStatusFilter = filter),
            emptyMessage: 'No upcoming appointments found.',
          ),
          // ── Past Tab Content ──────────────────────────────────────────────
          _AppointmentTabContent(
            appointments: _getAppointments(isUpcoming: false),
            selectedFilter: _selectedStatusFilter,
            onFilterChanged: (filter) => setState(() => _selectedStatusFilter = filter),
            emptyMessage: 'No past appointments recorded.',
          ),
        ],
      ),

      // ── Floating Action Button: Book New ───────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/public/choose-section'),
        backgroundColor: const Color(0xFF00796B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Book New',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // ── Bottom Navigation Bar (4 items) ───────────────────────────────────
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
                const SnackBar(content: Text('Downloading lab reports...')),
              );
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
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Appointments',
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
}

// ── Tab Content Widget with Status Filter Chips & Appointments List ───────────

class _AppointmentTabContent extends StatelessWidget {
  final List<Appointment> appointments;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final String emptyMessage;

  const _AppointmentTabContent({
    required this.appointments,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.emptyMessage,
  });

  static const _filters = ['All', 'Confirmed', 'Pending', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Status Filter Row
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final filter = _filters[i];
              final isSelected = filter == selectedFilter;
              return GestureDetector(
                onTap: () => onFilterChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00796B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Appointments List
        Expanded(
          child: appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy, size: 54, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(emptyMessage, style: AppTextStyles.subtitle),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _AppointmentCardFull(appointment: appointments[i]),
                ),
        ),
      ],
    );
  }
}

// ── Full Appointment Card ────────────────────────────────────────────────────

class _AppointmentCardFull extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCardFull({required this.appointment});

  Color get _statusColor {
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32); // Green
      case 'pending':
        return const Color(0xFFF57F17); // Yellow/Orange
      case 'completed':
        return const Color(0xFF1565C0); // Blue
      case 'cancelled':
        return const Color(0xFFD32F2F); // Red
      default:
        return AppColors.primary;
    }
  }

  Color get _statusBgColor {
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF8E1);
      case 'completed':
        return const Color(0xFFE3F2FD);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  IconData get _typeIcon {
    return appointment.appointmentType == 'Doctor Consultation'
        ? Icons.medical_services_outlined
        : Icons.science_outlined;
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
          // Header Row: Type Icon + Name + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_typeIcon, color: const Color(0xFF00796B), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorOrTestName,
                      style: AppTextStyles.headline3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appointment.appointmentType} • Ref: #${appointment.id}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.6),
          ),

          // Date & Time Row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF00796B)),
              const SizedBox(width: 6),
              Text(
                appointment.date,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF00796B)),
              const SizedBox(width: 6),
              Text(
                appointment.time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Patient ID Row
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Patient ID: ${appointment.patientId} (${appointment.patientName})',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location Row
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Booking Details Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFF00796B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.bookingDetails,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
