// lib/models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String username;
  final String role; // 'admin' | 'manager'
  final String token;
  final String phone;

  UserModel({
    required this.id, required this.name,
    required this.username, required this.role,
    required this.token, this.phone = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    username: j['username'] ?? '',
    role: j['role'] ?? 'manager',
    token: j['token'] ?? '',
    phone: j['phone'] ?? '',
  );
}
