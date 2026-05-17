// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style to match dark green theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A1A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Request Bluetooth permissions (Android 12+)
  await _requestPermissions();

  runApp(const LawnMowerApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
  ].request();
}

class LawnMowerApp extends StatelessWidget {
  const LawnMowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lawn Mower Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _SplashWrapper(),
    );
  }
}

/// Brief splash → HomeScreen transition
class _SplashWrapper extends StatefulWidget {
  const _SplashWrapper();

  @override
  State<_SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<_SplashWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  bool _goHome = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _goHome = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_goHome) return const HomeScreen();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A3A1A),
                  border: Border.all(
                      color: const Color(0xFF4CAF50), width: 2),
                ),
                child: const Icon(Icons.agriculture,
                    color: Color(0xFF4CAF50), size: 52),
              ),
              const SizedBox(height: 24),
              const Text(
                'LAWN MOWER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'CONTROLLER',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 13,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arduino Mega · HC-05/HC-06',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
