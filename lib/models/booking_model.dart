// lib/models/booking_model.dart

class BookingModel {
  final int? id;
  final String customerName;
  final String customerPhone;
  final DateTime bookingDate;
  final int batchId;
  final String batchName;
  final int managerId;
  final String managerName;
  final int guestCount;
  final String? notes;
  final String status; // 'confirmed', 'cancelled', 'pending'
  final DateTime createdAt;

  BookingModel({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.bookingDate,
    required this.batchId,
    required this.batchName,
    required this.managerId,
    required this.managerName,
    this.guestCount = 1,
    this.notes,
    this.status = 'confirmed',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'batch_id': batchId,
      'batch_name': batchName,
      'manager_id': managerId,
      'manager_name': managerName,
      'guest_count': guestCount,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      bookingDate: DateTime.parse(map['booking_date']),
      batchId: map['batch_id'],
      batchName: map['batch_name'],
      managerId: map['manager_id'],
      managerName: map['manager_name'],
      guestCount: map['guest_count'] ?? 1,
      notes: map['notes'],
      status: map['status'] ?? 'confirmed',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  BookingModel copyWith({
    int? id,
    String? customerName,
    String? customerPhone,
    DateTime? bookingDate,
    int? batchId,
    String? batchName,
    int? managerId,
    String? managerName,
    int? guestCount,
    String? notes,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      bookingDate: bookingDate ?? this.bookingDate,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      guestCount: guestCount ?? this.guestCount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
