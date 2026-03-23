// Mentor Model - yeh ek class hai jo mentor ki information store karti hai
// Simple words mein: Yeh ek template hai mentor data ke liye

class Mentor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String email;
  final String bio;
  final double rating;

  // Constructor - yeh mentor object banane ke liye use hota hai
  Mentor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.email,
    required this.bio,
    required this.rating,
  });
}
