import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/invoice_record.dart';
import '../../../services/shared_data_repository.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  PaymentStatus? _filterStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final allInvoices = sharedData.invoices;

    final filteredInvoices = allInvoices.where((inv) {
      final matchesSearch = inv.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.patientId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || inv.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Billing & Invoice Management'),
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
            // Search & Filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search Invoice #, Patient Name, ID...',
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
                          label: 'All Invoices',
                          isSelected: _filterStatus == null,
                          onTap: () => setState(() => _filterStatus = null),
                        ),
                        ...PaymentStatus.values.map((st) => _FilterChip(
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
              child: filteredInvoices.isEmpty
                  ? const Center(child: Text('No billing records found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredInvoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return _InvoiceCard(invoice: invoice);
                      },
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

class _InvoiceCard extends ConsumerWidget {
  final InvoiceRecord invoice;

  const _InvoiceCard({required this.invoice});

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
                invoice.invoiceNumber,
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              DropdownButton<PaymentStatus>(
                value: invoice.status,
                underline: const SizedBox(),
                items: PaymentStatus.values
                    .map((st) => DropdownMenuItem(
                          value: st,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusBg(st),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              st.displayName,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _statusText(st)),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    ref.read(sharedDataProvider.notifier).updateInvoiceStatus(invoice.invoiceNumber, newStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invoice ${invoice.invoiceNumber} updated to ${newStatus.displayName}')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(invoice.serviceName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Patient: ${invoice.patientName} (${invoice.patientId})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('Date: ${invoice.paymentDate} • Total Amount: ₹${invoice.totalAmount.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Generating PDF Invoice ${invoice.invoiceNumber}...')),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('PDF Invoice'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sending invoice to printer...')),
                  );
                },
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Print'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusBg(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFFE8F5E9);
      case PaymentStatus.pending:
        return const Color(0xFFFFF8E1);
      case PaymentStatus.cancelled:
        return const Color(0xFFFFEBEE);
      case PaymentStatus.refunded:
        return const Color(0xFFF3E5F5);
    }
  }

  Color _statusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFF2E7D32);
      case PaymentStatus.pending:
        return const Color(0xFFF57F17);
      case PaymentStatus.cancelled:
        return const Color(0xFFD32F2F);
      case PaymentStatus.refunded:
        return const Color(0xFF7B1FA2);
    }
  }
}
