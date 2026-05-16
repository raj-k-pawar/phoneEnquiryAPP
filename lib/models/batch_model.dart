// lib/models/batch_model.dart

class BatchModel {
  final int? id;
  final String name;
  final String startTime; // e.g., "9:00 AM"
  final String endTime;   // e.g., "2:00 PM"
  final int capacity;
  final bool isActive;

  BatchModel({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.isActive = true,
  });

  String get displayName => '$startTime - $endTime';
  String get fullName => name.isNotEmpty ? name : displayName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'capacity': capacity,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'],
      name: map['name'] ?? '',
      startTime: map['start_time'],
      endTime: map['end_time'],
      capacity: map['capacity'] ?? 50,
      isActive: map['is_active'] == 1,
    );
  }

  BatchModel copyWith({
    int? id,
    String? name,
    String? startTime,
    String? endTime,
    int? capacity,
    bool? isActive,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
    );
  }
}
