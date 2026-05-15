// lib/widgets/batch_summary_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/batch_model.dart';
import '../utils/app_theme.dart';

class BatchSummaryCard extends StatelessWidget {
  final BatchModel batch;
  final int bookingCount;
  final int colorIndex;
  final VoidCallback? onTap;

  const BatchSummaryCard({
    super.key,
    required this.batch,
    required this.bookingCount,
    required this.colorIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getBatchColor(colorIndex);
    final percent = batch.capacity > 0 ? (bookingCount / batch.capacity).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.access_time_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.fullName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      batch.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$bookingCount',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'bookings',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    'of ${batch.capacity}',
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== STATS CARD =====================

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subtitle!,
                      style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== SECTION HEADER =====================

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ===================== DATE HEADER =====================

class DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DateHeader({super.key, required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(selectedDate);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              isToday
                  ? 'Today, ${selectedDate.day} ${monthNames[selectedDate.month - 1]}'
                  : '${dayNames[selectedDate.weekday - 1]}, ${selectedDate.day} ${monthNames[selectedDate.month - 1]} ${selectedDate.year}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
