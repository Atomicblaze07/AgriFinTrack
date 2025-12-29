import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // IMPORTANT: initialize SQLite for Windows desktop
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const AgriFinTrackApp());
}

class AgriFinTrackApp extends StatelessWidget {
  const AgriFinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriFinTrack',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: AuthService().hasPin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final hasPin = snapshot.data!;
          return LoginScreen(isFirstTime: !hasPin);
        },
      ),
      routes: {
        DashboardScreen.routeName: (_) => const DashboardScreen(),
      },
    );
  }
}
