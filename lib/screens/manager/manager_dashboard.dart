// lib/screens/manager/manager_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/batch_model.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/batch_summary_card.dart';
import '../login_screen.dart';
import 'booking_enquiry_screen.dart';
import 'manager_bookings_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});
  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;
  List<BatchModel> _batches = [];
  Map<int, int> _bookingCounts = {};
  int _totalBookings = 0;
  bool _loading = true;
  final _db = DatabaseService();

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final managerId = auth.currentUser!.id!;
    try {
      final batches = await _db.getBatches(activeOnly: true);
      final counts = await _db.getBookingCountByBatchAndManager(_selectedDate, managerId);
      final allBookings = await _db.getBookingsByDateAndManager(_selectedDate, managerId);
      setState(() {
        _batches = batches;
        _bookingCounts = counts;
        _totalBookings = allBookings.length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() { _selectedDate = date; _showCalendar = false; _loading = true; });
    final auth = context.read<AuthProvider>();
    final counts = await _db.getBookingCountByBatchAndManager(date, auth.currentUser!.id!);
    final all = await _db.getBookingsByDateAndManager(date, auth.currentUser!.id!);
    setState(() { _bookingCounts = counts; _totalBookings = all.length; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manager Dashboard'),
          Text('Welcome, ${auth.currentUser?.name ?? "Manager"}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ]),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.nature_people_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats
            Row(children: [
              Expanded(child: StatsCard(
                title: "Today's Bookings", value: '$_totalBookings',
                icon: Icons.today_rounded, color: AppColors.primary, subtitle: 'Today')),
              const SizedBox(width: 12),
              Expanded(child: StatsCard(
                title: 'Active Batches', value: '${_batches.length}',
                icon: Icons.schedule_rounded, color: AppColors.batchColor3)),
            ]),
            const SizedBox(height: 20),

            // Date + section header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SectionHeader(title: 'My Bookings by Batch'),
              DateHeader(selectedDate: _selectedDate, onTap: () => setState(() => _showCalendar = !_showCalendar)),
            ]),

            // Calendar
            if (_showCalendar)
              Card(
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
                  onDaySelected: (s, _) => _onDateSelected(s),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.5), shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, titleCentered: true,
                    titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_batches.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No batches available', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
              ))
            else
              ...List.generate(_batches.length, (i) {
                final batch = _batches[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: BatchSummaryCard(
                    batch: batch,
                    bookingCount: _bookingCounts[batch.id] ?? 0,
                    colorIndex: i,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ManagerBookingsScreen(
                            date: _selectedDate, batchId: batch.id!, batchName: batch.fullName)))
                        .then((_) => _loadData()),
                  ),
                );
              }),

            const SizedBox(height: 20),
            SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _buildActionCard(
                  'New Booking', Icons.add_circle_rounded, AppColors.primary,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingEnquiryScreen()))
                      .then((_) => _loadData()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'All My Bookings', Icons.list_alt_rounded, AppColors.batchColor1,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManagerBookingsScreen(date: _selectedDate))),
                ),
              ),
            ]),
            const SizedBox(height: 20),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingEnquiryScreen()))
            .then((_) => _loadData()),
        icon: const Icon(Icons.add),
        label: Text('New Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
