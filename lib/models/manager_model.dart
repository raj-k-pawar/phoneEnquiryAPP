class ManagerModel {
  final int id;
  final String name;
  final String username;
  final String phone;
  final bool isActive;

  ManagerModel({
    required this.id,
    required this.name,
    required this.username,
    this.phone = '',
    this.isActive = true,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> j) => ManagerModel(
    id:       _parseInt(j['id']),
    name:     j['name']?.toString() ?? '',
    username: j['username']?.toString() ?? '',
    phone:    j['phone']?.toString() ?? '',
    isActive: j['is_active']?.toString() == '1',
  );

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
