import 'package:akshaja_insignia/src/presentation/auth/registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/home_screen.dart';
import 'package:akshaja_insignia/src/presentation/society_home_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhotoApp extends StatelessWidget {
  const PhotoApp({
    super.key,
    required this.repository,
    required this.firebaseAuthEnabled,
  });

  final PhotoRepository repository;
  final bool firebaseAuthEnabled;

  static const Color _brandPrimary = Color(0xFF3D3099);
  static const Color _brandSecondary = Color(0xFF6644D8);
  static const Color _brandSurface = Color(0xFFF5F1FF);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _brandPrimary,
      primary: _brandPrimary,
      secondary: _brandSecondary,
      surface: _brandSurface,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Akshaja Insignia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _brandSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: _brandSurface,
          foregroundColor: _brandPrimary,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _brandPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _brandPrimary,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!firebaseAuthEnabled) {
      return const SocietyHomeScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const RegistrationScreen();
        }
        return const SocietyHomeScreen();
      },
    );
  }
}
