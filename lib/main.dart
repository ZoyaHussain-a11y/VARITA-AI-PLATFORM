import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/database_service.dart';
import 'database/database_init.dart';

// Define global constants for the app's theme
const Color kPrimaryColor = Color(0xFFC2185B); // Doctor/Main App Color
const Color kPatientColor = Color(0xFF279FF4); // Patient Color
const Color kBackgroundColor = Color(0xFFF7F7F7);

void main() async {
  // Ensure Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Drift database
  final dbService = DatabaseService();
  await dbService.initialize();
  await DatabaseInitializer.initializeData(dbService.db);

  runApp(const VeritaApp());
}

class VeritaApp extends StatelessWidget {
  const VeritaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verita AI Health Platform',
      theme: ThemeData(
        // Set the primary theme color (used for things like the app bar if not overridden)
        primaryColor: kPrimaryColor,
        // Set the color scheme for a modern look
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kPatientColor,
          background: kBackgroundColor,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          color: kPrimaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Use a consistent font family if one is desired
        fontFamily: 'Roboto', // You can change this to your preferred font
        useMaterial3: true,
      ),
      // The entry point of the application is the SplashScreen
      home: const SplashScreen(),
    );
  }
}