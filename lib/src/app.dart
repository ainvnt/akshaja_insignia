import 'package:akshaja_insignia/src/presentation/auth/registration_screen.dart';
import 'package:akshaja_insignia/src/presentation/home_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akshaja Insignia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!firebaseAuthEnabled) {
      return HomeScreen(repository: repository);
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
        return HomeScreen(repository: repository);
      },
    );
  }
}
