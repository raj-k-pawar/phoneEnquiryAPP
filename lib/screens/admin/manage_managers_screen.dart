// lib/screens/admin/manage_managers_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class ManageManagersScreen extends StatefulWidget {
  const ManageManagersScreen({super.key});
  @override
  State<ManageManagersScreen> createState() => _ManageManagersScreenState();
}

class _ManageManagersScreenState extends State<ManageManagersScreen> {
  List<UserModel> _managers = [];
  bool _loading = true;
  final _db = DatabaseService();

  @override
  void initState() { super.initState(); _loadManagers(); }

  Future<void> _loadManagers() async {
    setState(() => _loading = true);
    final m = await _db.getManagers();
    setState(() { _managers = m; _loading = false; });
  }

  void _showManagerDialog({UserModel? manager}) {
    final nameCtrl = TextEditingController(text: manager?.name ?? '');
    final userCtrl = TextEditingController(text: manager?.username ?? '');
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: manager?.phone ?? '');
    bool obscure = true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(manager == null ? 'Add Manager' : 'Edit Manager',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: userCtrl,
                    decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email_rounded)),
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: manager == null ? 'Password' : 'New Password (leave blank to keep)',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setS(() => obscure = !obscure),
                    ),
                  ),
                  validator: (v) => manager == null && (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                    keyboardType: TextInputType.phone),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final exists = await _db.usernameExists(userCtrl.text.trim(), excludeId: manager?.id);
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username already taken'), backgroundColor: AppColors.error));
                  return;
                }
                final hash = passCtrl.text.isNotEmpty
                    ? _db.hashPassword(passCtrl.text)
                    : manager!.passwordHash;
                final u = UserModel(
                  id: manager?.id,
                  name: nameCtrl.text.trim(),
                  username: userCtrl.text.trim(),
                  passwordHash: hash,
                  role: 'manager',
                  phone: phoneCtrl.text.trim(),
                  createdAt: manager?.createdAt ?? DateTime.now(),
                );
                if (manager == null) await _db.addUser(u);
                else await _db.updateUser(u);
                if (mounted) Navigator.pop(context);
                _loadManagers();
              },
              child: Text(manager == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteManager(UserModel manager) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Remove ${manager.name}? Their bookings will remain.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) { await _db.deleteUser(manager.id!); _loadManagers(); }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.primary, AppColors.batchColor2, AppColors.batchColor1, AppColors.batchColor3, AppColors.accent];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Managers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_managers.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Row(children: [
                      Icon(Icons.people_rounded, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text('${_managers.length} Manager${_managers.length != 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ]),
                  ),
                Expanded(
                  child: _managers.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.person_add_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('No managers yet', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                        ]))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _managers.length,
                          itemBuilder: (_, i) {
                            final m = _managers[i];
                            final color = colors[i % colors.length];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  child: Text(_initials(m.name), style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, color: color, fontSize: 14)),
                                ),
                                title: Text(m.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('@${m.username}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                  if (m.phone != null && m.phone!.isNotEmpty)
                                    Text(m.phone!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                ]),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, size: 20),
                                    color: AppColors.textSecondary,
                                    onPressed: () => _showManagerDialog(manager: m),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, size: 20),
                                    color: AppColors.error,
                                    onPressed: () => _deleteManager(m),
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showManagerDialog(),
        icon: const Icon(Icons.person_add_rounded),
        label: Text('Add Manager', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
