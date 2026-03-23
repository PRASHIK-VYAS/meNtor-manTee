/// UserModel - Represents a user in the mentorship platform
/// Can be either a mentor or mentee
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "mentor" or "mentee"
  final String? phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    required this.createdAt,
  });

  // Create a copy with updated fields (useful for editing)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to Map (useful for future API integration)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map (useful for future API integration)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, createdAt: $createdAt)';
  }
}
