import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/enquiry_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AllEnquiriesScreen extends StatefulWidget {
  const AllEnquiriesScreen({super.key});
  @override State<AllEnquiriesScreen> createState() => _State();
}
class _State extends State<AllEnquiriesScreen> {
  DateTime _date = DateTime.now();
  List<EnquiryModel> _all = [], _filtered = [];
  bool _loading = true, _showCal = false;
  final _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final date = DateFormat('yyyy-MM-dd').format(_date);
    final data = await ApiService.getEnquiriesByDate(date);
    setState(() { _all = data; _filtered = data; _loading = false; });
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty ? _all : _all.where((e) =>
        e.customerName.toLowerCase().contains(q.toLowerCase()) ||
        e.mobile.contains(q) || e.batchName.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('All Enquiries'),
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimaryDark, kPrimary]))),
    ),
    body: Column(children: [
      Container(color: kPrimary, padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(children: [
        TextField(
          controller: _searchCtrl, onChanged: _search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search name, phone, batch...',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () { _searchCtrl.clear(); _search(''); })
                : null,
            filled: true, fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_filtered.length} enquiries', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          DateChip(date: _date, onTap: () => setState(() => _showCal = !_showCal)),
        ]),
      ])),
      if (_showCal) Card(margin: const EdgeInsets.all(8), child: TableCalendar(
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
      Expanded(child: _loading ? const LoadingOverlay(message: 'Loading enquiries...')
          : _filtered.isEmpty ? const EmptyState(title: 'No enquiries', subtitle: 'Try a different date or search', icon: Icons.search_off_rounded)
          : RefreshIndicator(onRefresh: _load, color: kPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => EnquiryCard(enquiry: _filtered[i], accent: batchColor(i % 6), index: i),
              ))),
    ]),
  );
}
