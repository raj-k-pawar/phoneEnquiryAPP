import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// ── Section Header ────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title; final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: kTextPrimary)),
      if (trailing != null) trailing!,
    ]),
  );
}

// ── Date Chip ─────────────────────────────────────
class DateChip extends StatelessWidget {
  final DateTime date; final VoidCallback onTap;
  const DateChip({super.key, required this.date, required this.onTap});
  bool get _isToday {
    final n = DateTime.now();
    return date.year == n.year && date.month == n.month && date.day == n.day;
  }
  String get _label {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return _isToday
        ? 'Today, ${date.day} ${months[date.month-1]}'
        : '${date.day} ${months[date.month-1]} ${date.year}';
  }
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today_rounded, color: kPrimary, size: 16),
        const SizedBox(width: 6),
        Text(_label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
        const Icon(Icons.arrow_drop_down_rounded, color: kPrimary),
      ]),
    ),
  );
}

// ── Stat Card ─────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title, value; final IconData icon; final Color color; final String? sub;
  const StatCard({super.key, required this.title, required this.value,
      required this.icon, required this.color, this.sub});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
          if (sub != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(sub!, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: kTextPrimary)),
        Text(title, style: GoogleFonts.poppins(fontSize: 11, color: kTextSecondary)),
      ],
    )),
  );
}

// ── Enquiry Card ──────────────────────────────────
class EnquiryCard extends StatelessWidget {
  final dynamic enquiry; final Color accent; final int index;
  const EnquiryCard({super.key, required this.enquiry, required this.accent, required this.index});
  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      CircleAvatar(backgroundColor: accent.withOpacity(0.15), radius: 22,
        child: Text(_initials(enquiry.customerName),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: accent, fontSize: 13))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(enquiry.customerName,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        Row(children: [
          const Icon(Icons.phone_outlined, size: 12, color: kTextSecondary),
          const SizedBox(width: 4),
          Text(enquiry.mobile, style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
        ]),
        Row(children: [
          const Icon(Icons.people_outline, size: 12, color: kTextSecondary),
          const SizedBox(width: 4),
          Text('${enquiry.numGuests} guests', style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
          const SizedBox(width: 8),
          const Icon(Icons.person_outline, size: 12, color: kTextSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(enquiry.managerName,
              style: GoogleFonts.poppins(fontSize: 11, color: kTextSecondary),
              overflow: TextOverflow.ellipsis)),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(enquiry.batchName.length > 10
              ? enquiry.batchName.substring(0,10) + '..'
              : enquiry.batchName,
              style: GoogleFonts.poppins(fontSize: 9, color: accent, fontWeight: FontWeight.w600))),
        const SizedBox(height: 4),
        Text(enquiry.createdAtFormatted,
            style: GoogleFonts.poppins(fontSize: 10, color: kTextSecondary)),
      ]),
    ])),
  );
}

// ── Loading Overlay ───────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final String? message;
  const LoadingOverlay({super.key, this.message});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: kPrimary),
      if (message != null) ...[
        const SizedBox(height: 12),
        Text(message!, style: GoogleFonts.poppins(color: kTextSecondary, fontSize: 13)),
      ],
    ],
  ));
}

// ── Empty State ───────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title, subtitle; final IconData icon;
  const EmptyState({super.key, required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 72, color: kTextSecondary.withOpacity(0.3)),
      const SizedBox(height: 16),
      Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: kTextSecondary)),
      const SizedBox(height: 4),
      Text(subtitle, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: kTextSecondary.withOpacity(0.7))),
    ]),
  ));
}
