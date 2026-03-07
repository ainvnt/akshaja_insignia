import 'package:akshaja_insignia/src/presentation/home_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';

class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key, required this.repository});

  final PhotoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akshaja Insignia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
