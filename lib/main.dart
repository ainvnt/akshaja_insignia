import 'package:akshaja_insignia/src/app.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = PhotoRepository(
    onLocalFilesDeleted: () {
      imageCache.clear();
      imageCache.clearLiveImages();
    },
  );
  await repository.initialize();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.repository});

  final PhotoRepository repository;

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
    return PhotoApp(repository: widget.repository);
  }
}
