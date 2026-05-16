// lib/screens/admin/all_customers_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/booking_model.dart';
import '../../models/batch_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/batch_summary_card.dart';

class AllCustomersScreen extends StatefulWidget {
  final DateTime? initialDate;
  final int? filterBatchId;

  const AllCustomersScreen({super.key, this.initialDate, this.filterBatchId});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  late DateTime _selectedDate;
  bool _showCalendar = false;
  List<BookingModel> _bookings = [];
  List<BatchModel> _batches = [];
  bool _loading = true;
  String _searchQuery = '';
  final _db = DatabaseService();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final bookings = await _db.getBookingsByDate(_selectedDate);
    final batches = await _db.getBatches(activeOnly: true);
    setState(() {
      _bookings = bookings;
      _batches = batches;
      _loading = false;
    });
  }

  List<BookingModel> get _filteredBookings {
    var list = widget.filterBatchId != null
        ? _bookings.where((b) => b.batchId == widget.filterBatchId).toList()
        : _bookings;
    if (_searchQuery.isNotEmpty) {
      list = list.where((b) =>
          b.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.customerPhone.contains(_searchQuery)).toList();
    }
    return list;
  }

  Map<int, List<BookingModel>> get _groupedByBatch {
    Map<int, List<BookingModel>> grouped = {};
    for (var b in _filteredBookings) {
      grouped.putIfAbsent(b.batchId, () => []).add(b);
    }
    return grouped;
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedByBatch;
    final colors = [AppColors.batchColor1, AppColors.batchColor2, AppColors.batchColor3, AppColors.batchColor4];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filterBatchId != null ? 'Batch Customers' : 'All Customers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Search
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        })
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Date picker row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_filteredBookings.length} bookings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  DateHeader(selectedDate: _selectedDate, onTap: () => setState(() => _showCalendar = !_showCalendar)),
                ],
              ),
              if (_showCalendar)
                Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2027, 12, 31),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
                    onDaySelected: (selected, _) {
                      setState(() { _selectedDate = selected; _showCalendar = false; });
                      _loadData();
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Color(0x8052B788), shape: BoxShape.circle),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('No bookings found', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: grouped.length,
                        itemBuilder: (_, gi) {
                          final batchId = grouped.keys.elementAt(gi);
                          final batchBookings = grouped[batchId]!;
                          final batchIdx = _batches.indexWhere((b) => b.id == batchId);
                          final color = colors[batchIdx >= 0 ? batchIdx % colors.length : gi % colors.length];
                          final batchName = batchBookings.first.batchName;

                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(batchName, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                  child: Text('${batchBookings.length}', style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                                ),
                              ]),
                            ),
                            ...batchBookings.map((booking) => _buildCustomerCard(booking, color)),
                            const SizedBox(height: 8),
                          ]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BookingModel booking, Color accentColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: accentColor.withOpacity(0.15),
            radius: 22,
            child: Text(_initials(booking.customerName), style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: accentColor, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              Row(children: [
                Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(booking.customerPhone, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ]),
              Row(children: [
                Icon(Icons.people_outline, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${booking.guestCount} guest${booking.guestCount != 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Text('by ${booking.managerName}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.7))),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: booking.status == 'confirmed'
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.status.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: booking.status == 'confirmed' ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
