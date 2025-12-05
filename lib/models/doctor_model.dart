class Doctor {
  final String name;
  final String specialty;
  final String imageUrl;
  final int patients;
  final double rating;
  final String description;
  final String education;
  final List<String> services;
  final String yearsExperience;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.patients,
    required this.rating,
    required this.description,
    required this.education,
    required this.services,
    required this.yearsExperience,
  });
}
