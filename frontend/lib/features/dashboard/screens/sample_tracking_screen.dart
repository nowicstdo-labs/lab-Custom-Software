import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/sample_record.dart';
import '../../../services/shared_data_repository.dart';
import '../../../services/api_service.dart';

class SampleTrackingScreen extends ConsumerStatefulWidget {
  const SampleTrackingScreen({super.key});

  @override
  ConsumerState<SampleTrackingScreen> createState() => _SampleTrackingScreenState();
}

class _SampleTrackingScreenState extends ConsumerState<SampleTrackingScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  SampleStatus? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final allSamples = sharedData.samples;

    final filteredSamples = allSamples.where((s) {
      final matchesSearch = s.sampleId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.testName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.patientId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || s.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Sample Tracking & QR Barcode'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            tooltip: 'Scan Sample QR',
            onPressed: () => _showScanQrModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search Sample ID, Patient ID, Test Name...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Samples',
                          isSelected: _filterStatus == null,
                          onTap: () => setState(() => _filterStatus = null),
                        ),
                        ...SampleStatus.values.map((st) => _FilterChip(
                              label: st.displayName,
                              isSelected: _filterStatus == st,
                              onTap: () => setState(() => _filterStatus = st),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredSamples.isEmpty
                  ? const Center(
                      child: Text('No samples found matching criteria.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSamples.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sample = filteredSamples[index];
                        return _SampleCard(sample: sample);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanQrModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 320,
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Icon(Icons.qr_code_scanner, size: 72, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Sample QR Code Scanner (API-Ready)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Align the sample barcode/QR code within the camera frame to instantly locate and open sample details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample ASTH-SMP-2026-00451 scanned successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Simulate QR Scan (ASTH-SMP-00451)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SampleCard extends ConsumerWidget {
  final SampleRecord sample;

  const _SampleCard({required this.sample});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sample.sampleId,
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(sample.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sample.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusTextColor(sample.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(sample.testName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Patient ID: ${sample.patientId} • Booking: ${sample.bookingId}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            'Sample Type: ${sample.sampleType} • Collected By: ${sample.collectedBy}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showQrModal(context, sample),
                icon: const Icon(Icons.qr_code, size: 16),
                label: const Text('View QR'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (sample.status == SampleStatus.samplePending) {
                      try {
                        await ApiService.patch('/samples/${sample.sampleId}/stage', {'stage': 'SAMPLE_COLLECTED'});
                      } catch (_) {}
                      ref.read(sharedDataProvider.notifier).updateSampleStatus(
                            sample.sampleId,
                            SampleStatus.sampleCollected,
                            collectedBy: 'Priya Sharma (Lab Tech)',
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sample ${sample.sampleId} marked as Collected.')),
                        );
                      }
                    } else if (sample.status == SampleStatus.sampleCollected) {
                      try {
                        await ApiService.patch('/samples/${sample.sampleId}/stage', {'stage': 'PROCESSING'});
                      } catch (_) {}
                      ref.read(sharedDataProvider.notifier).updateSampleStatus(
                            sample.sampleId,
                            SampleStatus.processing,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sample ${sample.sampleId} marked as Processing in Lab.')),
                        );
                      }
                    } else {
                      context.push('/lab-tech/result-entry?sampleId=${sample.sampleId}');
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(_actionButtonText(sample.status)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _actionButtonText(SampleStatus status) {
    switch (status) {
      case SampleStatus.samplePending:
        return 'Collect Sample';
      case SampleStatus.sampleCollected:
        return 'Receive in Lab';
      case SampleStatus.receivedInLab:
      case SampleStatus.processing:
        return 'Enter Test Results';
      case SampleStatus.completed:
        return 'View Test Results';
    }
  }

  Color _statusBgColor(SampleStatus status) {
    switch (status) {
      case SampleStatus.samplePending:
        return const Color(0xFFFFF8E1);
      case SampleStatus.sampleCollected:
        return const Color(0xFFE3F2FD);
      case SampleStatus.receivedInLab:
      case SampleStatus.processing:
        return const Color(0xFFE0F2F1);
      case SampleStatus.completed:
        return const Color(0xFFE8F5E9);
    }
  }

  Color _statusTextColor(SampleStatus status) {
    switch (status) {
      case SampleStatus.samplePending:
        return const Color(0xFFF57F17);
      case SampleStatus.sampleCollected:
        return const Color(0xFF1565C0);
      case SampleStatus.receivedInLab:
      case SampleStatus.processing:
        return const Color(0xFF00796B);
      case SampleStatus.completed:
        return const Color(0xFF2E7D32);
    }
  }

  void _showQrModal(BuildContext context, SampleRecord sample) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text('Sample QR: ${sample.sampleId}')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_2, size: 140, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Test: ${sample.testName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Patient ID: ${sample.patientId}'),
            const SizedBox(height: 8),
            Text(
              'Secure Token: ${sample.qrToken}',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
