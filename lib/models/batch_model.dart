class BatchModel {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int capacity;
  final bool isActive;

  BatchModel({
    required this.id, required this.name,
    required this.startTime, required this.endTime,
    this.capacity = 50, this.isActive = true,
  });

  String get displayTime => '$startTime – $endTime';

  factory BatchModel.fromJson(Map<String, dynamic> j) => BatchModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    startTime: j['start_time'] ?? '',
    endTime: j['end_time'] ?? '',
    capacity: j['capacity'] is int ? j['capacity'] : int.parse(j['capacity'].toString()),
    isActive: j['is_active'].toString() == '1',
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'start_time': startTime,
    'end_time': endTime, 'capacity': capacity,
  };
}
