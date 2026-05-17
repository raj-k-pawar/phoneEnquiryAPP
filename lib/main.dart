import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/manager/manager_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: const JankiApp(),
  ));
}

class JankiApp extends StatelessWidget {
  const JankiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Janki Agro Tourism',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.75, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    Widget next;
    if (!auth.loggedIn)      next = const LoginScreen();
    else if (auth.isAdmin)   next = const AdminDashboard();
    else                     next = const ManagerDashboard();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [kPrimaryDark, kPrimary, Color(0xFF52B788)],
      )),
      child: Center(child: FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
            child: const Icon(Icons.nature_people_rounded, color: Colors.white, size: 56)),
          const SizedBox(height: 24),
          const Text('Janki Agro Tourism',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text('Enquiry Management',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75))),
          const SizedBox(height: 48),
          SizedBox(width: 30, height: 30,
            child: CircularProgressIndicator(color: Colors.white.withOpacity(0.8), strokeWidth: 2.5)),
        ]),
      ))),
    ),
  );
}
