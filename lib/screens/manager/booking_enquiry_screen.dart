// lib/screens/manager/booking_enquiry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/batch_model.dart';
import '../../models/booking_model.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class BookingEnquiryScreen extends StatefulWidget {
  const BookingEnquiryScreen({super.key});
  @override
  State<BookingEnquiryScreen> createState() => _BookingEnquiryScreenState();
}

class _BookingEnquiryScreenState extends State<BookingEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;
  BatchModel? _selectedBatch;
  List<BatchModel> _batches = [];
  bool _loading = false;
  bool _submitting = false;
  final _db = DatabaseService();

  @override
  void initState() { super.initState(); _loadBatches(); }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _guestCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    setState(() => _loading = true);
    final b = await _db.getBatches(activeOnly: true);
    setState(() { _batches = b; _loading = false; });
  }

  String _formatDate(DateTime d) {
    return DateFormat('EEE, dd MMM yyyy').format(d);
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch'), backgroundColor: AppColors.warning));
      return;
    }

    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();

    try {
      final booking = BookingModel(
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        bookingDate: _selectedDate,
        batchId: _selectedBatch!.id!,
        batchName: _selectedBatch!.fullName,
        managerId: auth.currentUser!.id!,
        managerName: auth.currentUser!.name,
        guestCount: int.tryParse(_guestCtrl.text) ?? 1,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await _db.addBooking(booking);

      if (mounted) {
        setState(() => _submitting = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 8),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Booking Confirmed!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 8),
              Text('${_nameCtrl.text.trim()}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(_selectedBatch!.fullName, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
              Text(_formatDate(_selectedDate), style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
            ]),
            actions: [
              ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nameCtrl.clear(); _phoneCtrl.clear();
                  _guestCtrl.text = '1'; _notesCtrl.clear();
                  setState(() { _selectedBatch = null; _selectedDate = DateTime.now(); });
                },
                child: Text('New Booking', style: GoogleFonts.poppins(color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Enquiry'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      const Icon(Icons.nature_people_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('New Booking', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('Fill in customer details', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Customer info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Customer Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter customer name' : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone_outlined)),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter phone number';
                            if (v.trim().length < 10) return 'Enter valid phone number';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _guestCtrl,
                          decoration: const InputDecoration(labelText: 'Number of Guests', prefixIcon: Icon(Icons.people_outline_rounded)),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            if (int.tryParse(v) == null || int.parse(v) < 1) return 'Enter valid number';
                            return null;
                          },
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Booking Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => setState(() => _showCalendar = !_showCalendar),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _showCalendar ? AppColors.primary : AppColors.divider,
                                  width: _showCalendar ? 2 : 1),
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Text(_formatDate(_selectedDate), style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14)),
                              const Spacer(),
                              Icon(_showCalendar ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primary),
                            ]),
                          ),
                        ),
                        if (_showCalendar)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay: DateTime.utc(2027, 12, 31),
                              focusedDay: _selectedDate,
                              selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
                              onDaySelected: (s, _) => setState(() { _selectedDate = s; _showCalendar = false; }),
                              calendarStyle: const CalendarStyle(
                                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                todayDecoration: BoxDecoration(color: Color(0x8052B788), shape: BoxShape.circle),
                              ),
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false, titleCentered: true,
                                titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Batch selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Select Batch *', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Tap to select a time slot', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        if (_batches.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('No batches available. Contact admin.', style: GoogleFonts.poppins(color: AppColors.warning, fontSize: 13)),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8),
                            itemCount: _batches.length,
                            itemBuilder: (_, i) {
                              final batch = _batches[i];
                              final isSelected = _selectedBatch?.id == batch.id;
                              final color = AppTheme.getBatchColor(i);
                              return GestureDetector(
                                onTap: () => setState(() => _selectedBatch = batch),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.withOpacity(0.12) : const Color(0xFFF0F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? color : AppColors.divider,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      Icon(Icons.access_time_rounded, size: 16, color: isSelected ? color : AppColors.textSecondary),
                                      const Spacer(),
                                      if (isSelected) Icon(Icons.check_circle_rounded, size: 16, color: color),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(batch.name.isNotEmpty ? batch.name : 'Batch ${i+1}',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600, fontSize: 12,
                                            color: isSelected ? color : AppColors.textPrimary)),
                                    Text(batch.displayName, style: GoogleFonts.poppins(
                                        fontSize: 11, color: isSelected ? color.withOpacity(0.8) : AppColors.textSecondary)),
                                  ]),
                                ),
                              );
                            },
                          ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          prefixIcon: Icon(Icons.note_outlined),
                          hintText: 'Special requirements, preferences...',
                        ),
                        maxLines: 3,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submitting ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    child: _submitting
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 22),
                            const SizedBox(width: 8),
                            Text('Confirm Booking', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                          ]),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
    );
  }
}
