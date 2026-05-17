// lib/models/enquiry_model.dart
class EnquiryModel {
  final int id;
  final String customerName;
  final String mobile;
  final int numGuests;
  final String visitDate;
  final int batchId;
  final String batchName;
  final int managerId;
  final String managerName;
  final String notes;
  final String createdAt;
  final String createdAtFormatted;
  final String startTime;
  final String endTime;

  EnquiryModel({
    required this.id, required this.customerName,
    required this.mobile, required this.numGuests,
    required this.visitDate, required this.batchId,
    required this.batchName, required this.managerId,
    required this.managerName, this.notes = '',
    this.createdAt = '', this.createdAtFormatted = '',
    this.startTime = '', this.endTime = '',
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> j) => EnquiryModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    customerName: j['customer_name'] ?? '',
    mobile: j['mobile'] ?? '',
    numGuests: j['num_guests'] is int ? j['num_guests'] : int.parse(j['num_guests'].toString()),
    visitDate: j['visit_date'] ?? '',
    batchId: j['batch_id'] is int ? j['batch_id'] : int.parse(j['batch_id'].toString()),
    batchName: j['batch_name'] ?? '',
    managerId: j['manager_id'] is int ? j['manager_id'] : int.parse(j['manager_id'].toString()),
    managerName: j['manager_name'] ?? '',
    notes: j['notes'] ?? '',
    createdAt: j['created_at'] ?? '',
    createdAtFormatted: j['created_at_formatted'] ?? '',
    startTime: j['start_time'] ?? '',
    endTime: j['end_time'] ?? '',
  );
}

// lib/models/manager_model.dart
class ManagerModel {
  final int id;
  final String name;
  final String username;
  final String phone;
  final bool isActive;

  ManagerModel({
    required this.id, required this.name,
    required this.username, this.phone = '', this.isActive = true,
  });

  factory ManagerModel.fromJson(Map<String, dynamic> j) => ManagerModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    username: j['username'] ?? '',
    phone: j['phone'] ?? '',
    isActive: j['is_active'].toString() == '1',
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'username': username, 'phone': phone,
  };
}

// lib/models/batch_report_model.dart
class BatchReportModel {
  final int batchId;
  final String batchName;
  final String startTime;
  final String endTime;
  final int capacity;
  final int totalCalls;
  final int totalGuests;
  final List<EnquiryModel> enquiries;

  BatchReportModel({
    required this.batchId, required this.batchName,
    required this.startTime, required this.endTime,
    required this.capacity, required this.totalCalls,
    required this.totalGuests, required this.enquiries,
  });

  factory BatchReportModel.fromJson(Map<String, dynamic> j) => BatchReportModel(
    batchId: j['batch_id'] is int ? j['batch_id'] : int.parse(j['batch_id'].toString()),
    batchName: j['batch_name'] ?? '',
    startTime: j['start_time'] ?? '',
    endTime: j['end_time'] ?? '',
    capacity: j['capacity'] is int ? j['capacity'] : int.parse(j['capacity'].toString()),
    totalCalls: j['total_calls'] is int ? j['total_calls'] : int.parse(j['total_calls'].toString()),
    totalGuests: j['total_guests'] is int ? j['total_guests'] : int.parse(j['total_guests'].toString()),
    enquiries: (j['enquiries'] as List? ?? [])
        .map((e) => EnquiryModel.fromJson(e)).toList(),
  );
}
