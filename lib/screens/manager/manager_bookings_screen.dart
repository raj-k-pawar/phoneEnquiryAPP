// lib/screens/manager/manager_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/booking_model.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/batch_summary_card.dart';

class ManagerBookingsScreen extends StatefulWidget {
  final DateTime date;
  final int? batchId;
  final String? batchName;

  const ManagerBookingsScreen({super.key, required this.date, this.batchId, this.batchName});

  @override
  State<ManagerBookingsScreen> createState() => _ManagerBookingsScreenState();
}

class _ManagerBookingsScreenState extends State<ManagerBookingsScreen> {
  late DateTime _selectedDate;
  bool _showCalendar = false;
  List<BookingModel> _bookings = [];
  bool _loading = true;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    List<BookingModel> b;
    if (widget.batchId != null) {
      final all = await _db.getBookingsByDateAndManager(_selectedDate, auth.currentUser!.id!);
      b = all.where((bk) => bk.batchId == widget.batchId).toList();
    } else {
      b = await _db.getBookingsByDateAndManager(_selectedDate, auth.currentUser!.id!);
    }
    setState(() { _bookings = b; _loading = false; });
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.batchColor1, AppColors.batchColor2, AppColors.batchColor3, AppColors.primary];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batchName ?? 'My Bookings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_bookings.length} booking${_bookings.length != 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              DateHeader(selectedDate: _selectedDate, onTap: () => setState(() => _showCalendar = !_showCalendar)),
            ]),
            if (_showCalendar)
              Card(
                margin: const EdgeInsets.only(top: 10),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
                  onDaySelected: (s, _) {
                    setState(() { _selectedDate = s; _showCalendar = false; });
                    _loadBookings();
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: Color(0x8052B788), shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, titleCentered: true,
                    titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('No bookings for this date', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) {
                        final booking = _bookings[i];
                        final color = colors[i % colors.length];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(children: [
                              Row(children: [
                                CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  radius: 22,
                                  child: Text(_initials(booking.customerName), style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600, color: color, fontSize: 13)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(booking.customerName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                    Row(children: [
                                      Icon(Icons.phone_outlined, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
                                      Text(booking.customerPhone, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                    ]),
                                  ]),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.batchColor1.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(booking.batchName, style: GoogleFonts.poppins(
                                      fontSize: 10, color: AppColors.batchColor1, fontWeight: FontWeight.w600)),
                                ),
                              ]),
                              if (booking.notes != null && booking.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(children: [
                                    Icon(Icons.note_outlined, size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(booking.notes!,
                                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
                                  ]),
                                ),
                              const SizedBox(height: 4),
                              Row(children: [
                                const SizedBox(width: 54),
                                Icon(Icons.people_outline, size: 13, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text('${booking.guestCount} guest${booking.guestCount != 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: Text('Cancel Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                        content: Text('Cancel booking for ${booking.customerName}?', style: GoogleFonts.poppins()),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Yes, Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _db.cancelBooking(booking.id!);
                                      _loadBookings();
                                    }
                                  },
                                  child: booking.status == 'cancelled'
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text('Cancelled', style: GoogleFonts.poppins(
                                              fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text('Cancel', style: GoogleFonts.poppins(
                                              fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
                                        ),
                                ),
                              ]),
                            ]),
                          ),
                        );
                      },
                    ),
        ),
      ]),
    );
  }
}
