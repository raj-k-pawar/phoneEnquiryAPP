import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class ManageBatchesScreen extends StatefulWidget {
  const ManageBatchesScreen({super.key});
  @override State<ManageBatchesScreen> createState() => _ManageBatchesScreenState();
}

class _ManageBatchesScreenState extends State<ManageBatchesScreen> {
  List<BatchModel> _batches = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final b = await ApiService.getBatches();
    setState(() { _batches = b; _loading = false; });
  }

  void _showDialog({BatchModel? batch}) {
    final nameCtrl  = TextEditingController(text: batch?.name ?? '');
    final startCtrl = TextEditingController(text: batch?.startTime ?? '');
    final endCtrl   = TextEditingController(text: batch?.endTime ?? '');
    final capCtrl   = TextEditingController(text: batch?.capacity.toString() ?? '50');
    final formKey   = GlobalKey<FormState>();
    bool saving     = false;

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(batch == null ? 'Add Batch' : 'Edit Batch',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Batch Name'),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Time (e.g. 9:00 AM)'),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Time (e.g. 2:00 PM)'),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Capacity'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: kTextSecondary))),
        ElevatedButton(
          onPressed: saving ? null : () async {
            if (!formKey.currentState!.validate()) return;
            setS(() => saving = true);
            final data = {'name': nameCtrl.text.trim(), 'start_time': startCtrl.text.trim(),
                'end_time': endCtrl.text.trim(), 'capacity': int.tryParse(capCtrl.text) ?? 50};
            Map<String, dynamic> res;
            if (batch == null) res = await ApiService.addBatch(data);
            else res = await ApiService.updateBatch(batch.id, data);
            if (mounted) Navigator.pop(context);
            if (res['success'] == true) _load();
            else { ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Error'), backgroundColor: kError)); }
          },
          child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(batch == null ? 'Add' : 'Update'),
        ),
      ],
    )));
  }

  Future<void> _delete(BatchModel b) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Batch', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text('Delete "${b.name}"?', style: GoogleFonts.poppins()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kError),
            onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    ));
    if (ok == true) { await ApiService.deleteBatch(b.id); _load(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Manage Batches'),
      flexibleSpace: Container(decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [kPrimaryDark, kPrimary]))),
    ),
    body: _loading ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : RefreshIndicator(onRefresh: _load, color: kPrimary,
            child: _batches.isEmpty
                ? const Center(child: Text('No batches. Tap + to add.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _batches.length,
                    itemBuilder: (_, i) {
                      final b = _batches[i]; final color = batchColor(i);
                      return Card(child: ListTile(
                        leading: Container(width: 44, height: 44,
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.access_time_rounded, color: color)),
                        title: Text(b.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text('${b.startTime} – ${b.endTime} · Cap: ${b.capacity}',
                            style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_rounded, size: 20), color: kTextSecondary,
                              onPressed: () => _showDialog(batch: b)),
                          IconButton(icon: const Icon(Icons.delete_rounded, size: 20), color: kError,
                              onPressed: () => _delete(b)),
                        ]),
                      ));
                    },
                  )),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showDialog(),
      icon: const Icon(Icons.add), label: Text('Add Batch', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
    ),
  );
}
