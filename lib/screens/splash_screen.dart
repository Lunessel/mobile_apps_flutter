import 'package:flutter/material.dart';
import 'package:mobile_app/data/service_locator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final user = await ServiceLocator.auth.getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      await Navigator.pushReplacementNamed(context, '/home');
    } else {
      await Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grass, size: 80, color: Colors.teal),
            SizedBox(height: 24),
            Text(
              'Hydro Monitor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Smart Hydroponics Monitoring',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
