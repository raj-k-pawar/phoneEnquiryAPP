// lib/screens/admin/admin_dashboard.dart

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
import 'manage_batches_screen.dart';
import 'manage_managers_screen.dart';
import 'all_customers_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;
  List<BatchModel> _batches = [];
  Map<int, int> _bookingCounts = {};
  Map<String, int> _stats = {};
  bool _loading = true;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final batches = await _db.getBatches(activeOnly: true);
      final counts = await _db.getBookingCountByBatch(_selectedDate);
      final stats = await _db.getDashboardStats();
      setState(() {
        _batches = batches;
        _bookingCounts = counts;
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _showCalendar = false;
      _loading = true;
    });
    final counts = await _db.getBookingCountByBatch(date);
    setState(() {
      _bookingCounts = counts;
      _loading = false;
    });
  }

  int get _totalTodayBookings => _bookingCounts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.nature_people_rounded, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard'),
            Text(
              'Welcome, ${auth.currentUser?.name ?? "Admin"}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: "Today's Bookings",
                      value: '$_totalTodayBookings',
                      icon: Icons.today_rounded,
                      color: AppColors.primary,
                      subtitle: 'Today',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Total Bookings',
                      value: '${_stats['total'] ?? 0}',
                      icon: Icons.book_online_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Managers',
                      value: '${_stats['managers'] ?? 0}',
                      icon: Icons.people_rounded,
                      color: AppColors.batchColor2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Active Batches',
                      value: '${_batches.length}',
                      icon: Icons.schedule_rounded,
                      color: AppColors.batchColor3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(title: 'Bookings by Batch'),
                  DateHeader(
                    selectedDate: _selectedDate,
                    onTap: () => setState(() => _showCalendar = !_showCalendar),
                  ),
                ],
              ),

              // Calendar
              if (_showCalendar)
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2027, 12, 31),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                    onDaySelected: (selected, focused) => _onDateSelected(selected),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: AppColors.error),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Batch booking cards
              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ))
              else if (_batches.isEmpty)
                _emptyState('No batches configured', 'Add batches from Manage Batches', Icons.schedule_rounded)
              else
                ...List.generate(_batches.length, (i) {
                  final batch = _batches[i];
                  final count = _bookingCounts[batch.id] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: BatchSummaryCard(
                      batch: batch,
                      bookingCount: count,
                      colorIndex: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllCustomersScreen(
                          initialDate: _selectedDate,
                          filterBatchId: batch.id,
                        )),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Action buttons
              SectionHeader(title: 'Management'),
              const SizedBox(height: 8),
              _buildActionGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      _ActionItem('Manage Batches', Icons.schedule_rounded, AppColors.batchColor1,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBatchesScreen())).then((_) => _loadData())),
      _ActionItem('Managers', Icons.people_rounded, AppColors.batchColor2,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageManagersScreen())).then((_) => _loadData())),
      _ActionItem('All Customers', Icons.group_rounded, AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllCustomersScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) => _buildActionCard(actions[i]),
    );
  }

  Widget _buildActionCard(_ActionItem item) {
    return Card(
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 60, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ActionItem(this.label, this.icon, this.color, this.onTap);
}
