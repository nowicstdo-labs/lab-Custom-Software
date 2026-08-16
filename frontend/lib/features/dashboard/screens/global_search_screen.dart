import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/shared_data_repository.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);

    final matchingBookings = _query.isEmpty
        ? []
        : sharedData.bookings.where((b) {
            return b.bookingId.toLowerCase().contains(_query.toLowerCase()) ||
                b.patientName.toLowerCase().contains(_query.toLowerCase()) ||
                b.patientId.toLowerCase().contains(_query.toLowerCase()) ||
                b.testName.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    final matchingSamples = _query.isEmpty
        ? []
        : sharedData.samples.where((s) {
            return s.sampleId.toLowerCase().contains(_query.toLowerCase()) ||
                s.testName.toLowerCase().contains(_query.toLowerCase()) ||
                s.patientId.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    final matchingReports = _query.isEmpty
        ? []
        : sharedData.reports.where((r) {
            return r.reportId.toLowerCase().contains(_query.toLowerCase()) ||
                r.patientName.toLowerCase().contains(_query.toLowerCase()) ||
                r.testName.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    final matchingInvoices = _query.isEmpty
        ? []
        : sharedData.invoices.where((inv) {
            return inv.invoiceNumber.toLowerCase().contains(_query.toLowerCase()) ||
                inv.patientName.toLowerCase().contains(_query.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Global Search'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search Patient, Patient ID, Phone, Booking, Sample, Report, Invoice...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.search, size: 64, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text('Type to search across all lab records...', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (matchingBookings.isNotEmpty) ...[
                            _SectionHeader(title: 'Test & Doctor Bookings (${matchingBookings.length})'),
                            ...matchingBookings.map((b) => _SearchResultCard(
                                  title: b.testName,
                                  subtitle: 'Booking ID: ${b.bookingId} • Patient: ${b.patientName} (${b.patientId})',
                                  chipLabel: b.bookingStatus,
                                  onTap: () => context.push('/public/my-tests'),
                                )),
                            const SizedBox(height: 16),
                          ],

                          if (matchingSamples.isNotEmpty) ...[
                            _SectionHeader(title: 'Laboratory Samples (${matchingSamples.length})'),
                            ...matchingSamples.map((s) => _SearchResultCard(
                                  title: 'Sample ${s.sampleId}',
                                  subtitle: 'Test: ${s.testName} • Patient ID: ${s.patientId}',
                                  chipLabel: s.status.name,
                                  onTap: () => context.push('/lab-tech/samples'),
                                )),
                            const SizedBox(height: 16),
                          ],

                          if (matchingReports.isNotEmpty) ...[
                            _SectionHeader(title: 'Lab Reports (${matchingReports.length})'),
                            ...matchingReports.map((r) => _SearchResultCard(
                                  title: 'Report ${r.reportId}',
                                  subtitle: 'Test: ${r.testName} • Patient: ${r.patientName}',
                                  chipLabel: r.status.name,
                                  onTap: () => context.push('/pdf-report?reportId=${r.reportId}'),
                                )),
                            const SizedBox(height: 16),
                          ],

                          if (matchingInvoices.isNotEmpty) ...[
                            _SectionHeader(title: 'Invoices (${matchingInvoices.length})'),
                            ...matchingInvoices.map((inv) => _SearchResultCard(
                                  title: 'Invoice ${inv.invoiceNumber}',
                                  subtitle: 'Patient: ${inv.patientName} • Amount: ₹${inv.totalAmount.toInt()}',
                                  chipLabel: inv.status.name,
                                  onTap: () => context.push('/billing'),
                                )),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String chipLabel;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.title,
    required this.subtitle,
    required this.chipLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(chipLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
            ),
          ],
        ),
      ),
    );
  }
}
