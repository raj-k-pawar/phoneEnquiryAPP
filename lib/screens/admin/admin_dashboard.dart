import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../login_screen.dart';
import 'manage_batches_screen.dart';
import 'manage_managers_screen.dart';
import 'all_enquiries_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTime _selectedDate = DateTime.now();
  bool _showCal = false;
  List<BatchReportModel> _report = [];
  bool _loading = true;
  int _totalCalls = 0, _totalGuests = 0;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final report = await ApiService.getBatchReport(date);
    int calls = 0, guests = 0;
    for (var b in report) { calls += b.totalCalls; guests += b.totalGuests; }
    setState(() { _report = report; _totalCalls = calls; _totalGuests = guests; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [kPrimaryDark, kPrimary]))),
        leading: Container(margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.nature_people_rounded, color: Colors.white)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Admin Dashboard'),
          Text('Welcome, ${auth.user?.name ?? "Admin"}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () async {
            await auth.logout();
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load, color: kPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats row
            Row(children: [
              Expanded(child: StatCard(title: "Today's Calls", value: '$_totalCalls',
                  icon: Icons.phone_rounded, color: kPrimary, sub: 'Today')),
              const SizedBox(width: 10),
              Expanded(child: StatCard(title: 'Total Guests', value: '$_totalGuests',
                  icon: Icons.people_rounded, color: const Color(0xFF9C27B0))),
            ]),
            const SizedBox(height: 16),
            // Date + section
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SectionHeader(title: 'Batch-wise Report'),
              DateChip(date: _selectedDate, onTap: () => setState(() => _showCal = !_showCal)),
            ]),
            if (_showCal) Card(child: TableCalendar(
              firstDay: DateTime.utc(2024,1,1), lastDay: DateTime.utc(2027,12,31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
              onDaySelected: (s, _) { setState(() { _selectedDate = s; _showCal = false; }); _load(); },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: kPrimaryLight.withOpacity(0.5), shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(height: 8),
            if (_loading) const LoadingOverlay(message: 'Loading report...')
            else if (_report.isEmpty) const EmptyState(
                title: 'No data', subtitle: 'No enquiries for this date', icon: Icons.inbox_rounded)
            else ..._report.asMap().entries.map((e) => _batchCard(e.value, e.key)).toList(),
            const SizedBox(height: 16),
            SectionHeader(title: 'Management'),
            const SizedBox(height: 8),
            _managementGrid(),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _batchCard(BatchReportModel batch, int idx) {
    final color = batchColor(idx);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.access_time_rounded, color: color)),
          title: Text(batch.batchName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('${batch.startTime} – ${batch.endTime}',
              style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${batch.totalCalls}', style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, fontSize: 18, color: color)),
            Text('calls', style: GoogleFonts.poppins(fontSize: 10, color: kTextSecondary)),
          ]),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child:
              Row(children: [
                _miniStat('📞 Calls', '${batch.totalCalls}', color),
                const SizedBox(width: 12),
                _miniStat('👥 Guests', '${batch.totalGuests}', color),
                const SizedBox(width: 12),
                _miniStat('🏕 Capacity', '${batch.capacity}', kTextSecondary),
              ]),
            ),
            if (batch.enquiries.isEmpty)
              Padding(padding: const EdgeInsets.all(16),
                child: Text('No enquiries yet', style: GoogleFonts.poppins(color: kTextSecondary, fontSize: 13)))
            else
              ...batch.enquiries.map((e) => EnquiryCard(enquiry: e, accent: color, index: idx)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
      Text(label, style: GoogleFonts.poppins(fontSize: 9, color: kTextSecondary)),
    ]),
  ));

  Widget _managementGrid() {
    final items = [
      _MgmtItem('Batches', Icons.schedule_rounded, kPrimary, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBatchesScreen())).then((_) => _load())),
      _MgmtItem('Managers', Icons.people_rounded, const Color(0xFF9C27B0), () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageManagersScreen()))),
      _MgmtItem('All Enquiries', Icons.list_alt_rounded, const Color(0xFF2196F3), () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AllEnquiriesScreen()))),
    ];
    return GridView.count(crossAxisCount: 3, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
      children: items.map((i) => Card(child: InkWell(
        onTap: i.onTap, borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: i.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(i.icon, color: i.color, size: 24)),
          const SizedBox(height: 8),
          Text(i.label, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
        ])),
      ))).toList(),
    );
  }
}

class _MgmtItem { final String label; final IconData icon; final Color color; final VoidCallback onTap;
  _MgmtItem(this.label, this.icon, this.color, this.onTap); }
