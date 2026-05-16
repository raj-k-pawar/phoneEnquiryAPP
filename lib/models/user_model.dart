// lib/models/user_model.dart

class UserModel {
  final int? id;
  final String name;
  final String username;
  final String passwordHash;
  final String role; // 'admin' or 'manager'
  final String? phone;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.passwordHash,
    required this.role,
    this.phone,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      passwordHash: map['password_hash'],
      role: map['role'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? passwordHash,
    String? role,
    String? phone,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
