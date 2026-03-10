import 'package:akshaja_insignia/src/app.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseEnabled =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  if (firebaseEnabled) {
    await Firebase.initializeApp();
  }

  final repository = PhotoRepository(
    onLocalFilesDeleted: () {
      imageCache.clear();
      imageCache.clearLiveImages();
    },
  );
  await repository.initialize();

  runApp(MyApp(repository: repository, firebaseEnabled: firebaseEnabled));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.repository,
    required this.firebaseEnabled,
  });

  final PhotoRepository repository;
  final bool firebaseEnabled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhotoApp(
      repository: widget.repository,
      firebaseAuthEnabled: widget.firebaseEnabled,
    );
  }
}
