class LabTest {
  final String id;
  final String name;
  final String category;
  final String description;
  final String sampleType;
  final String turnaround; // e.g. 'Same Day', '24 Hrs'
  final String preparation;
  final double price;

  const LabTest({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.sampleType,
    required this.turnaround,
    required this.preparation,
    required this.price,
  });
}
