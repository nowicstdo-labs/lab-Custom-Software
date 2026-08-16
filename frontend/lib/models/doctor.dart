// Doctor model
// API-ready structure: replace localImagePath with a network URL field when backend is available.

class Doctor {
  final String id;
  final String name;
  final String qualification;
  final String specialization;
  final String experience;
  final String availability;
  final String consultationFee;
  final String about;
  /// Path to a local asset image (e.g. 'assets/images/doctor_male_1.png').
  /// When the backend is ready, replace this with a URL string.
  final String? localImagePath;
  final double rating;
  final int patientsServed;

  const Doctor({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experience,
    required this.availability,
    required this.consultationFee,
    required this.about,
    this.localImagePath,
    this.rating = 4.5,
    this.patientsServed = 500,
  });
}
