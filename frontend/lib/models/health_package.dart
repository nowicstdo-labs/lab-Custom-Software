class HealthPackage {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final List<String> includes;

  const HealthPackage({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.includes,
  });
}
