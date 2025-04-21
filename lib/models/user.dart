class User {
  final String id;
  final String name;
  final String avatar;
  final String role;
  final String? specialization;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    this.specialization,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] ?? 'assets/images/doctor.png',
      role: json['role'] ?? 'user',
      specialization: json['specialization'],
    );
  }

}
