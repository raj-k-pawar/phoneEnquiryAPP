import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'admin/admin_dashboard.dart';
import 'manager/manager_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _obscure     = true;
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override void dispose() { _anim.dispose(); _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_userCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => auth.isAdmin ? const AdminDashboard() : const ManagerDashboard(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [kPrimaryDark, kPrimary, Color(0xFF40916C)],
        )),
        child: SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
            child: Column(children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.nature_people_rounded, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 16),
              Text('Janki Agro Tourism', style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
              Text('Enquiry Management', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 36),
              // Card
              Card(
                elevation: 16, shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(padding: const EdgeInsets.all(28), child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Sign In', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Enter your credentials', style: GoogleFonts.poppins(fontSize: 13, color: kTextSecondary)),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline_rounded)),
                      validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(builder: (_, auth, __) {
                      if (auth.error != null) return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: kError.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: kError, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(auth.error!, style: GoogleFonts.poppins(color: kError, fontSize: 12))),
                        ]),
                      );
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 18),
                    Consumer<AuthProvider>(builder: (_, auth, __) => ElevatedButton(
                      onPressed: auth.loading ? null : _login,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      child: auth.loading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Sign In', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                    )),
                  ]),
                )),
              ),
              const SizedBox(height: 16),
              Text('Admin: admin / admin123', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
            ]),
          )),
        ))),
      ),
    );
  }
}
