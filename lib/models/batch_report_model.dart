import 'enquiry_model.dart';

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
    required this.batchId,
    required this.batchName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.totalCalls,
    required this.totalGuests,
    required this.enquiries,
  });

  factory BatchReportModel.fromJson(Map<String, dynamic> j) => BatchReportModel(
    batchId:     _parseInt(j['batch_id']),
    batchName:   j['batch_name']?.toString() ?? '',
    startTime:   j['start_time']?.toString() ?? '',
    endTime:     j['end_time']?.toString() ?? '',
    capacity:    _parseInt(j['capacity']),
    totalCalls:  _parseInt(j['total_calls']),
    totalGuests: _parseInt(j['total_guests']),
    enquiries:   (j['enquiries'] as List? ?? [])
        .map((e) => EnquiryModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
