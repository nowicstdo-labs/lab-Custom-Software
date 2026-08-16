import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/doctor.dart';
import '../../../utils/dummy_data.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  Doctor? _doctor;
  String? _selectedSlotTime;

  @override
  void initState() {
    super.initState();
    _doctor = mockDoctors.where((d) => d.id == widget.doctorId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    if (_doctor == null) {
      return const Scaffold(
        body: Center(child: Text('Doctor not found.')),
      );
    }

    final doctor = _doctor!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF006B8E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Doctor PNG – large, centered
                      Hero(
                        tag: 'doctor-${doctor.id}',
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: doctor.localImagePath != null
                              ? Image.asset(
                                  doctor.localImagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                )
                              : const Icon(Icons.person, size: 80, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        doctor.name,
                        style: AppTextStyles.headline3.copyWith(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  _StatsRow(doctor: doctor),
                  const SizedBox(height: 24),

                  // Info card
                  _InfoCard(doctor: doctor),
                  const SizedBox(height: 24),

                  // About
                  Text('About', style: AppTextStyles.headline3.copyWith(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(doctor.about, style: AppTextStyles.body.copyWith(height: 1.6)),
                  const SizedBox(height: 28),

                  // Time slot section
                  _SlotSection(
                    selectedSlot: _selectedSlotTime,
                    onSlotSelected: (time) => setState(() => _selectedSlotTime = time),
                  ),
                  const SizedBox(height: 32),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/public/book-appointment?doctorId=${doctor.id}&slot=${_selectedSlotTime ?? ''}',
                        );
                      },
                      icon: const Icon(Icons.calendar_today_rounded, color: Colors.white),
                      label: Text(
                        _selectedSlotTime == null
                            ? 'Select a time slot above'
                            : 'Book Appointment at $_selectedSlotTime',
                        style: AppTextStyles.button.copyWith(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Doctor doctor;
  const _StatsRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(icon: Icons.star_rounded, value: '${doctor.rating}', label: 'Rating', color: const Color(0xFFFFC107)),
        const SizedBox(width: 12),
        _StatChip(icon: Icons.people_alt_outlined, value: '${doctor.patientsServed}+', label: 'Patients', color: AppColors.primary),
        const SizedBox(width: 12),
        _StatChip(icon: Icons.currency_rupee, value: doctor.consultationFee.replaceAll('₹ ', ''), label: 'Fee', color: AppColors.secondary),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.headline3.copyWith(color: color, fontSize: 16)),
            Text(label, style: AppTextStyles.body.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Doctor doctor;
  const _InfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.school_outlined, label: 'Qualification', value: doctor.qualification),
          const _Divider(),
          _InfoRow(icon: Icons.work_outline, label: 'Experience', value: doctor.experience),
          const _Divider(),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Availability', value: doctor.availability),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 0.5, indent: 50);
}

// ── Time Slot Section ─────────────────────────────────────────────────────────

class _SlotSection extends StatelessWidget {
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const _SlotSection({required this.selectedSlot, required this.onSlotSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a Time Slot', style: AppTextStyles.headline3.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        Text(
          'Each slot holds up to 10 patients. Select an available time.',
          style: AppTextStyles.body.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Grid of slots
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: mockAppointmentSlots.length,
          itemBuilder: (context, i) {
            final slot = mockAppointmentSlots[i];
            final isSelected = selectedSlot == slot.time;
            return _SlotCard(
              slot: slot,
              isSelected: isSelected,
              onTap: () {
                if (slot.isFull) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.block, color: Colors.white, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('This slot is already booked. Please select another slot.'),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFD32F2F),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }
                onSlotSelected(slot.time);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // Legend
        _SlotLegend(),
      ],
    );
  }
}

// ── Slot Card ─────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  final AppointmentSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotCard({required this.slot, required this.isSelected, required this.onTap});

  Color get _bgColor {
    if (isSelected) return const Color(0xFF1565C0);
    if (slot.isFull) return const Color(0xFFFFEBEE);
    if (slot.isAlmostFull) return const Color(0xFFFFF8E1);
    return const Color(0xFFE8F5E9);
  }

  Color get _borderColor {
    if (isSelected) return const Color(0xFF1565C0);
    if (slot.isFull) return const Color(0xFFEF9A9A);
    if (slot.isAlmostFull) return const Color(0xFFFFCC02);
    return const Color(0xFF66BB6A);
  }

  Color get _textColor {
    if (isSelected) return Colors.white;
    if (slot.isFull) return const Color(0xFFD32F2F);
    if (slot.isAlmostFull) return const Color(0xFFF57F17);
    return const Color(0xFF2E7D32);
  }

  String get _statusLabel {
    if (slot.isFull) return 'FULL';
    if (isSelected) return 'Selected';
    if (slot.isAlmostFull) return 'Almost Full';
    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 1.4),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time + status badge on same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.time,
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _textColor.withValues(alpha: isSelected ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Booking count
            Text(
              '${slot.bookedCount} / ${slot.maxCapacity} booked',
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            // "Only N slots left" for almost full
            if (slot.isAlmostFull && !slot.isFull)
              Text(
                'Only ${slot.remaining} slot${slot.remaining == 1 ? '' : 's'} left',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _SlotLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(color: const Color(0xFF66BB6A), label: 'Available'),
          _LegendItem(color: const Color(0xFF1565C0), label: 'Selected'),
          _LegendItem(color: const Color(0xFFFFCC02), label: 'Almost Full'),
          _LegendItem(color: const Color(0xFFEF9A9A), label: 'Full'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
