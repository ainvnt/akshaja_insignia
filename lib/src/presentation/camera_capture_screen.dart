import 'dart:async';

import 'package:akshaja_insignia/src/domain/photo_draft.dart';
import 'package:akshaja_insignia/src/presentation/photo_preview_screen.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/services/location_service.dart';
import 'package:akshaja_insignia/src/services/permission_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key, required this.repository});

  final PhotoRepository repository;

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final PermissionService _permissionService = const PermissionService();
  final LocationService _locationService = const LocationService();

  CameraController? _cameraController;
  Future<void>? _cameraInitialization;
  bool _initializing = true;
  bool _permissionsGranted = false;
  bool _capturing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      final permissionsGranted = await _permissionService
          .requestCapturePermissions();

      if (!mounted) {
        return;
      }

      if (!permissionsGranted) {
        setState(() {
          _permissionsGranted = false;
          _initializing = false;
          _errorText =
              'Camera, location, and media permissions are required to continue.';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No camera found on device.');
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      final initFuture = controller.initialize();
      _cameraInitialization = initFuture;
      await initFuture;

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _permissionsGranted = true;
        _initializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initializing = false;
        _errorText = 'Camera initialization failed: $error';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() {
      _capturing = true;
    });

    try {
      final capturedAt = DateTime.now();
      final locationFuture = _locationService.getCurrentLocation();
      final imageFile = await controller.takePicture();

      var latitude = 0.0;
      var longitude = 0.0;
      var locationUnavailable = false;
      try {
        final location = await locationFuture.timeout(
          const Duration(seconds: 8),
        );
        latitude = location.latitude;
        longitude = location.longitude;
      } catch (_) {
        // Continue with a fallback coordinate when GPS is slow/unavailable.
        locationUnavailable = true;
      }

      if (!mounted) {
        return;
      }

      if (locationUnavailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location unavailable. Photo captured without GPS coordinates.',
            ),
          ),
        );
      }

      final draft = PhotoDraft(
        tempFilePath: imageFile.path,
        capturedAt: capturedAt,
        latitude: latitude,
        longitude: longitude,
      );

      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) =>
              PhotoPreviewScreen(draft: draft, repository: widget.repository),
        ),
      );

      if (saved == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Capture failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _capturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_cameraController?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_permissionsGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorText ?? 'Permissions are required.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _initializing = true;
                    _errorText = null;
                  });
                  unawaited(_initialize());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || _cameraInitialization == null) {
      return Center(child: Text(_errorText ?? 'Camera unavailable.'));
    }

    return FutureBuilder<void>(
      future: _cameraInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Camera error: ${snapshot.error}'));
        }

        return Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: FloatingActionButton(
                  onPressed: _capturing ? null : _capturePhoto,
                  child: _capturing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
