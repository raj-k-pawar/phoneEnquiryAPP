// lib/screens/admin/manage_managers_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/manager_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class ManageManagersScreen extends StatefulWidget {
  const ManageManagersScreen({super.key});
  @override State<ManageManagersScreen> createState() => _State();
}
class _State extends State<ManageManagersScreen> {
  List<ManagerModel> _managers = [];
  bool _loading = true;
  final _colors = [kPrimary, Color(0xFF9C27B0), Color(0xFF2196F3), Color(0xFFFF5722), Color(0xFF00BCD4)];

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    final m = await ApiService.getManagers();
    setState(() { _managers = m; _loading = false; });
  }
  String _initials(String n) { final p = n.trim().split(' ');
    return p.length >= 2 ? '${p[0][0]}${p[1][0]}'.toUpperCase() : n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase(); }

  void _showDialog({ManagerModel? mgr}) {
    final nameCtrl  = TextEditingController(text: mgr?.name ?? '');
    final userCtrl  = TextEditingController(text: mgr?.username ?? '');
    final passCtrl  = TextEditingController();
    final phoneCtrl = TextEditingController(text: mgr?.phone ?? '');
    bool obscure    = true, saving = false;
    final formKey   = GlobalKey<FormState>();

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(mgr == null ? 'Add Manager' : 'Edit Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: passCtrl, obscureText: obscure,
            decoration: InputDecoration(labelText: mgr == null ? 'Password *' : 'New Password (optional)',
                suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setS(() => obscure = !obscure))),
            validator: (v) => mgr == null && (v == null || v.isEmpty) ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: kTextSecondary))),
        ElevatedButton(
          onPressed: saving ? null : () async {
            if (!formKey.currentState!.validate()) return;
            setS(() => saving = true);
            final data = {'name': nameCtrl.text.trim(), 'username': userCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(), if (passCtrl.text.isNotEmpty) 'password': passCtrl.text};
            final res = mgr == null ? await ApiService.addManager(data) : await ApiService.updateManager(mgr.id, data);
            if (mounted) Navigator.pop(context);
            if (res['success'] == true) _load();
            else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error'), backgroundColor: kError));
          },
          child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(mgr == null ? 'Add' : 'Update'),
        ),
      ],
    )));
  }

  Future<void> _delete(ManagerModel m) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Remove Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text('Remove ${m.name}?', style: GoogleFonts.poppins()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kError),
            onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
      ],
    ));
    if (ok == true) { await ApiService.deleteManager(m.id); _load(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manage Managers'),
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimaryDark, kPrimary])))),
    body: _loading ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : RefreshIndicator(onRefresh: _load, color: kPrimary,
            child: _managers.isEmpty
                ? const Center(child: Text('No managers. Tap + to add.'))
                : ListView.builder(padding: const EdgeInsets.all(16), itemCount: _managers.length,
                    itemBuilder: (_, i) {
                      final m = _managers[i]; final color = _colors[i % _colors.length];
                      return Card(child: ListTile(
                        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15),
                          child: Text(_initials(m.name), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: color, fontSize: 13))),
                        title: Text(m.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('@${m.username}', style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
                          if (m.phone.isNotEmpty) Text(m.phone, style: GoogleFonts.poppins(fontSize: 12, color: kTextSecondary)),
                        ]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_rounded, size: 20), color: kTextSecondary, onPressed: () => _showDialog(mgr: m)),
                          IconButton(icon: const Icon(Icons.delete_rounded, size: 20), color: kError, onPressed: () => _delete(m)),
                        ]),
                      ));
                    })),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showDialog(),
      icon: const Icon(Icons.person_add_rounded),
      label: Text('Add Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
    ),
  );
}
