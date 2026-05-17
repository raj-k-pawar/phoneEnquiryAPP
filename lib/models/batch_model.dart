class BatchModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int capacity;
  final bool isActive;

  BatchModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.capacity = 50,
    this.isActive = true,
  });

  String get displayTime => '$startTime – $endTime';

  factory BatchModel.fromJson(Map<String, dynamic> j) => BatchModel(
    id:        _parseInt(j['id']),
    name:      j['name']?.toString() ?? '',
    startTime: j['start_time']?.toString() ?? '',
    endTime:   j['end_time']?.toString() ?? '',
    capacity:  _parseInt(j['capacity']),
    isActive:  j['is_active']?.toString() == '1',
  );

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'start_time': startTime,
    'end_time': endTime,
    'capacity': capacity,
  };
}
