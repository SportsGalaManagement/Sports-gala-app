import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SportsGalaApp());
}

class SportsGalaApp extends StatelessWidget {
  const SportsGalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sports Gala 2026',

      // 🔹 Professional Dark Blue Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1D2671), // Dark Blue

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D2671),
          primary: const Color(0xFF1D2671),    // Deep Dark Blue
          secondary: const Color(0xFF3949AB),  // Professional Indigo/Blue
          surface: Colors.white,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF8F9FD), // Light blue-grey tint

        // 🔹 Customizing AppBar globally
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1D2671),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // 🔹 FIXED: CardThemeData for professional cards
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Buttons theme for consistency
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D2671),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
