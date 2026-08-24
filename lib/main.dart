// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'screens/admin_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LatinDelightApp());
}

class LatinDelightApp extends StatelessWidget {
  const LatinDelightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.nombreNegocio,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConfig.moradoOscuro,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.moradoOscuro,
          secondary: AppConfig.amarillo,
        ),
        scaffoldBackgroundColor: AppConfig.blanco,
        useMaterial3: true,
      ),
      home: const AdminHomeScreen(),
    );
  }
}
