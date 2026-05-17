import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});
  @override State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _guestCtrl  = TextEditingController(text: '1');
  final _notesCtrl  = TextEditingController();

  DateTime _visitDate  = DateTime.now();
  bool _showCal        = false;
  BatchModel? _selectedBatch;
  List<BatchModel> _batches = [];
  bool _loadingBatches = true, _submitting = false;

  @override
  void initState() { super.initState(); _loadBatches(); }
  @override
  void dispose() {
    _nameCtrl.dispose(); _mobileCtrl.dispose();
    _guestCtrl.dispose(); _notesCtrl.dispose(); super.dispose();
  }

  Future<void> _loadBatches() async {
    final b = await ApiService.getBatches();
    setState(() { _batches = b.where((x) => x.isActive).toList(); _loadingBatches = false; });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a batch'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final res  = await ApiService.addEnquiry({
      'customer_name': _nameCtrl.text.trim(),
      'mobile':        _mobileCtrl.text.trim(),
      'num_guests':    int.tryParse(_guestCtrl.text) ?? 1,
      'visit_date':    DateFormat('yyyy-MM-dd').format(_visitDate),
      'batch_id':      _selectedBatch!.id,
      'manager_id':    auth.user?.id,
      'notes':         _notesCtrl.text.trim(),
    });
    setState(() => _submitting = false);
    if (!mounted) return;

    if (res['success'] == true) {
      await showDialog(context: context, builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 64, height: 64,
            decoration: BoxDecoration(color: kSuccess.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: kSuccess, size: 36)),
          const SizedBox(height: 16),
          Text('Enquiry Saved!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 6),
          Text(_nameCtrl.text.trim(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kTextSecondary)),
          Text(_selectedBatch!.name, style: GoogleFonts.poppins(color: kTextSecondary, fontSize: 13)),
          Text(DateFormat('dd MMM yyyy').format(_visitDate), style: GoogleFonts.poppins(color: kTextSecondary, fontSize: 13)),
        ]),
        actions: [
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _nameCtrl.clear(); _mobileCtrl.clear(); _guestCtrl.text = '1';
            _notesCtrl.clear(); setState(() { _selectedBatch = null; _visitDate = DateTime.now(); });
          }, child: Text('Add Another', style: GoogleFonts.poppins(color: kPrimary))),
        ],
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Failed to save'), backgroundColor: kError));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('New Enquiry'),
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimaryDark, kPrimary]))),
    ),
    body: _loadingBatches
        ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Header
              Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]),
                  borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.nature_people_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('New Booking', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Fill customer details below', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  ]),
                ])),
              // Customer Details
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                Text('Customer Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                TextFormField(controller: _nameCtrl, textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                  textInputAction: TextInputAction.next),
                const SizedBox(height: 12),
                TextFormField(controller: _mobileCtrl, keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Mobile required';
                    if (v.trim().length < 10) return 'Enter valid mobile';
                    return null;
                  }, textInputAction: TextInputAction.next),
                const SizedBox(height: 12),
                TextFormField(controller: _guestCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Number of Guests *', prefixIcon: Icon(Icons.people_outline_rounded)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if ((int.tryParse(v) ?? 0) < 1) return 'Min 1 guest';
                    return null;
                  }),
              ]))),
              const SizedBox(height: 8),
              // Visit Date
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Visit Date *', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(() => _showCal = !_showCal),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F2), borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _showCal ? kPrimary : kDivider, width: _showCal ? 2 : 1)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, color: kPrimary, size: 20),
                      const SizedBox(width: 10),
                      Text(DateFormat('EEE, dd MMM yyyy').format(_visitDate),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: kPrimary, fontSize: 14)),
                      const Spacer(),
                      Icon(_showCal ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: kPrimary),
                    ])),
                ),
                if (_showCal) Padding(padding: const EdgeInsets.only(top: 12), child: TableCalendar(
                  firstDay: DateTime.now(), lastDay: DateTime.utc(2027,12,31),
                  focusedDay: _visitDate, selectedDayPredicate: (d) => isSameDay(d, _visitDate),
                  onDaySelected: (s, _) => setState(() { _visitDate = s; _showCal = false; }),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: Color(0x8052B788), shape: BoxShape.circle),
                  ),
                  headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                )),
              ]))),
              const SizedBox(height: 8),
              // Batch Selection
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Select Batch *', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Tap a time slot below', style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
                const SizedBox(height: 12),
                if (_batches.isEmpty)
                  Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text('No batches available. Contact admin.', style: GoogleFonts.poppins(color: Colors.orange)))
                else
                  GridView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8),
                    itemCount: _batches.length,
                    itemBuilder: (_, i) {
                      final b = _batches[i]; final isSelected = _selectedBatch?.id == b.id;
                      final color = batchColor(i);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedBatch = b),
                        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.12) : const Color(0xFFF0F7F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? color : kDivider, width: isSelected ? 2 : 1)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(Icons.access_time_rounded, size: 14, color: isSelected ? color : kTextSecondary),
                              const Spacer(),
                              if (isSelected) Icon(Icons.check_circle_rounded, size: 14, color: color),
                            ]),
                            const SizedBox(height: 4),
                            Text(b.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12,
                                color: isSelected ? color : kTextPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(b.displayTime, style: GoogleFonts.poppins(fontSize: 10,
                                color: isSelected ? color.withOpacity(0.8) : kTextSecondary)),
                          ]),
                        ),
                      );
                    },
                  ),
              ]))),
              const SizedBox(height: 8),
              // Notes
              Card(child: Padding(padding: const EdgeInsets.all(16), child:
                TextFormField(controller: _notesCtrl, maxLines: 3, minLines: 1,
                  decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.note_outlined),
                      hintText: 'Special requirements...')))),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                child: _submitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text('Take Enquiry', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
              ),
              const SizedBox(height: 20),
            ])),
          ),
  );
}
