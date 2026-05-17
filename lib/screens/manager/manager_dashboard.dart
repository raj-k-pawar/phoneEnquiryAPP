// lib/screens/manager/manager_dashboard.dart
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
import 'booking_form.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});
  @override State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  DateTime _date = DateTime.now();
  bool _showCal = false, _loading = true;
  List<EnquiryModel> _enquiries = [];
  List<BatchReportModel> _report = [];
  final _searchCtrl = TextEditingController();
  List<EnquiryModel> _filtered = [];

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final date = DateFormat('yyyy-MM-dd').format(_date);
    final enquiries = await ApiService.getEnquiriesByDate(date, managerId: auth.user?.id);
    final report    = await ApiService.getBatchReport(date);
    setState(() { _enquiries = enquiries; _filtered = enquiries; _report = report; _loading = false; });
  }

  void _search(String q) {
    setState(() { _filtered = q.isEmpty ? _enquiries
        : _enquiries.where((e) => e.customerName.toLowerCase().contains(q.toLowerCase()) || e.mobile.contains(q)).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: Container(margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.nature_people_rounded, color: Colors.white)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My Enquiries'),
          Text('${auth.user?.name ?? "Manager"}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: () async {
            await auth.logout();
            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimaryDark, kPrimary]))),
      ),
      body: RefreshIndicator(
        onRefresh: _load, color: kPrimary,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            // Stats
            Row(children: [
              Expanded(child: StatCard(title: 'My Calls Today', value: '${_enquiries.length}',
                  icon: Icons.phone_rounded, color: kPrimary)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(title: 'Guests Today', value: '${_enquiries.fold(0, (s, e) => s + e.numGuests)}',
                  icon: Icons.people_rounded, color: const Color(0xFF9C27B0))),
            ]),
            const SizedBox(height: 14),
            // Batch summary
            ..._report.asMap().entries.map((e) {
              final b = e.value; final color = batchColor(e.key);
              final myCount = _enquiries.where((eq) => eq.batchId == b.batchId).length;
              return Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.access_time_rounded, color: color, size: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.batchName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${b.startTime} – ${b.endTime}', style: GoogleFonts.poppins(fontSize: 11, color: kTextSecondary)),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                    value: b.capacity > 0 ? (b.totalCalls / b.capacity).clamp(0.0, 1.0) : 0,
                    backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation(color), minHeight: 4)),
                ])),
                const SizedBox(width: 10),
                Column(children: [
                  Text('$myCount', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                  Text('my calls', style: GoogleFonts.poppins(fontSize: 9, color: kTextSecondary)),
                ]),
              ])));
            }).toList(),
            const SizedBox(height: 14),
            // Date + search
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              SectionHeader(title: 'My Enquiries'),
              DateChip(date: _date, onTap: () => setState(() => _showCal = !_showCal)),
            ]),
            if (_showCal) Card(child: TableCalendar(
              firstDay: DateTime.utc(2024,1,1), lastDay: DateTime.utc(2027,12,31),
              focusedDay: _date, selectedDayPredicate: (d) => isSameDay(d, _date),
              onDaySelected: (s, _) { setState(() { _date = s; _showCal = false; }); _load(); },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: kPrimaryLight.withOpacity(0.5), shape: BoxShape.circle),
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            )),
            TextField(
              controller: _searchCtrl, onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Search name or phone...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 8),
          ]))),
          _loading ? const SliverFillRemaining(child: LoadingOverlay(message: 'Loading...'))
          : _filtered.isEmpty ? const SliverFillRemaining(
              child: EmptyState(title: 'No enquiries', subtitle: 'Tap + to add a new booking', icon: Icons.inbox_rounded))
          : SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => EnquiryCard(enquiry: _filtered[i], accent: batchColor(i % 6), index: i),
                childCount: _filtered.length,
              ))),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingForm()))
            .then((_) => _load()),
        icon: const Icon(Icons.add), label: Text('New Enquiry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
