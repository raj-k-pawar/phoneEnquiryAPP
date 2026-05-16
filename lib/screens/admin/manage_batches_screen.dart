// lib/screens/admin/manage_batches_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/batch_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class ManageBatchesScreen extends StatefulWidget {
  const ManageBatchesScreen({super.key});
  @override
  State<ManageBatchesScreen> createState() => _ManageBatchesScreenState();
}

class _ManageBatchesScreenState extends State<ManageBatchesScreen> {
  List<BatchModel> _batches = [];
  bool _loading = true;
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loading = true);
    final b = await _db.getBatches();
    setState(() { _batches = b; _loading = false; });
  }

  void _showBatchDialog({BatchModel? batch}) {
    final nameCtrl = TextEditingController(text: batch?.name ?? '');
    final startCtrl = TextEditingController(text: batch?.startTime ?? '');
    final endCtrl = TextEditingController(text: batch?.endTime ?? '');
    final capCtrl = TextEditingController(text: batch?.capacity.toString() ?? '50');
    bool isActive = batch?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(batch == null ? 'Add Batch' : 'Edit Batch',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Batch Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: startCtrl,
                    decoration: const InputDecoration(labelText: 'Start Time (e.g. 9:00 AM)'),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: endCtrl,
                    decoration: const InputDecoration(labelText: 'End Time (e.g. 2:00 PM)'),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: capCtrl,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text('Active', style: GoogleFonts.poppins(fontSize: 14)),
                  value: isActive,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setS(() => isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final b = BatchModel(
                  id: batch?.id,
                  name: nameCtrl.text.trim(),
                  startTime: startCtrl.text.trim(),
                  endTime: endCtrl.text.trim(),
                  capacity: int.tryParse(capCtrl.text) ?? 50,
                  isActive: isActive,
                );
                if (batch == null) await _db.addBatch(b);
                else await _db.updateBatch(b);
                if (mounted) Navigator.pop(context);
                _loadBatches();
              },
              child: Text(batch == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBatch(BatchModel batch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Batch', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Delete "${batch.fullName}"? This cannot be undone.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteBatch(batch.id!);
      _loadBatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Batches'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.schedule_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No batches yet', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                  Text('Tap + to add your first batch', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.7))),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _batches.length,
                  itemBuilder: (_, i) {
                    final batch = _batches[i];
                    final color = AppTheme.getBatchColor(i);
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.access_time_rounded, color: color),
                        ),
                        title: Text(batch.fullName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(batch.displayName, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Text('Capacity: ${batch.capacity}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: batch.isActive ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                batch.isActive ? 'Active' : 'Inactive',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: batch.isActive ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ]),
                        ]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            color: AppColors.textSecondary,
                            onPressed: () => _showBatchDialog(batch: batch),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, size: 20),
                            color: AppColors.error,
                            onPressed: () => _deleteBatch(batch),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBatchDialog(),
        icon: const Icon(Icons.add),
        label: Text('Add Batch', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
