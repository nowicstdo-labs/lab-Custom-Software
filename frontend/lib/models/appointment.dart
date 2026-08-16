class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorOrTestName;
  final String appointmentType; // 'Doctor Consultation' or 'Lab Test'
  final String date;
  final String time;
  final String location;
  final String status; // 'Confirmed', 'Pending', 'Completed', 'Cancelled'
  final String bookingDetails;
  final bool isUpcoming;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorOrTestName,
    required this.appointmentType,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.bookingDetails,
    this.isUpcoming = true,
  });
}
