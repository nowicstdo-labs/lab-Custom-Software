enum PaymentStatus {
  paid,
  pending,
  cancelled,
  refunded,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

class InvoiceRecord {
  final String invoiceNumber; // e.g. ASTH-INV-2026-001
  final String bookingId;
  final String patientId;
  final String patientName;
  final String serviceName; // Test Name or Doctor Consultation
  final double price;
  final double discount;
  final double tax;
  final double totalAmount;
  final PaymentStatus status;
  final String paymentDate;

  const InvoiceRecord({
    required this.invoiceNumber,
    required this.bookingId,
    required this.patientId,
    required this.patientName,
    required this.serviceName,
    required this.price,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    required this.status,
    required this.paymentDate,
  });

  InvoiceRecord copyWith({
    String? invoiceNumber,
    String? bookingId,
    String? patientId,
    String? patientName,
    String? serviceName,
    double? price,
    double? discount,
    double? tax,
    double? totalAmount,
    PaymentStatus? status,
    String? paymentDate,
  }) {
    return InvoiceRecord(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      bookingId: bookingId ?? this.bookingId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }
}
