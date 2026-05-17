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
    required this.id,
    required this.customerName,
    required this.mobile,
    required this.numGuests,
    required this.visitDate,
    required this.batchId,
    required this.batchName,
    required this.managerId,
    required this.managerName,
    this.notes = '',
    this.createdAt = '',
    this.createdAtFormatted = '',
    this.startTime = '',
    this.endTime = '',
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> j) => EnquiryModel(
    id:                 _parseInt(j['id']),
    customerName:       j['customer_name']?.toString() ?? '',
    mobile:             j['mobile']?.toString() ?? '',
    numGuests:          _parseInt(j['num_guests']),
    visitDate:          j['visit_date']?.toString() ?? '',
    batchId:            _parseInt(j['batch_id']),
    batchName:          j['batch_name']?.toString() ?? '',
    managerId:          _parseInt(j['manager_id']),
    managerName:        j['manager_name']?.toString() ?? '',
    notes:              j['notes']?.toString() ?? '',
    createdAt:          j['created_at']?.toString() ?? '',
    createdAtFormatted: j['created_at_formatted']?.toString() ?? '',
    startTime:          j['start_time']?.toString() ?? '',
    endTime:            j['end_time']?.toString() ?? '',
  );

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
