import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/config/app_config.dart';
import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:intl/intl.dart';

class SavedPhotoPreviewScreen extends StatefulWidget {
  const SavedPhotoPreviewScreen({
    super.key,
    required this.photo,
    required this.repository,
  });

  final PhotoRecord photo;
  final PhotoRepository repository;

  @override
  State<SavedPhotoPreviewScreen> createState() =>
      _SavedPhotoPreviewScreenState();
}

class _SavedPhotoPreviewScreenState extends State<SavedPhotoPreviewScreen> {
  late PhotoRecord _photo;
  Future<Uint8List?>? _cloudBytesFuture;
  bool _restoring = false;
  bool _deletingPending = false;
  final TransformationController _zoomController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _photo = widget.photo;
    _cloudBytesFuture = _loadCloudBytes();
  }

  Future<Uint8List?> _loadCloudBytes() {
    return widget.repository.fetchCloudPhotoBytes(_photo);
  }

  Future<void> _storeLocally() async {
    setState(() {
      _restoring = true;
    });

    try {
      final restored = await widget.repository.restoreLocalCopyFromCloud(
        _photo,
      );
      if (!mounted) {
        return;
      }

      if (restored == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not store local copy')),
        );
        return;
      }

      setState(() {
        _photo = restored;
        _cloudBytesFuture = _loadCloudBytes();
      });
      _resetZoom();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Local copy stored')));
    } finally {
      if (mounted) {
        setState(() {
          _restoring = false;
        });
      }
    }
  }

  Future<void> _stopUploadAndDeletePending() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Stop upload and delete local file?'),
            content: const Text(
              'This photo is pending upload. This will cancel cloud upload and permanently delete the local file from this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete Permanently'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _deletingPending = true;
    });

    try {
      final deleted = await widget.repository.cancelPendingUploadAndDeleteLocal(
        _photo,
      );

      if (!mounted) {
        return;
      }

      if (!deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete failed. Please try again.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pending upload cancelled and deleted.')),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _deletingPending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captured = DateFormat(
      'dd MMM yyyy, hh:mm:ss a',
    ).format(_photo.capturedAt.toLocal());
    final localFile = File(_photo.filePath);
    final hasLocalFile = localFile.existsSync();
    final isLocalAvif = _photo.filePath.toLowerCase().endsWith('.avif');
    final canStoreLocally =
        !hasLocalFile && _photo.uploadStatus == UploadStatus.uploaded;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Photo Details'), centerTitle: true),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _buildPreviewPanel(hasLocalFile, isLocalAvif, localFile),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Capture Metadata',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _sourceChip(
                                hasLocalFile: hasLocalFile,
                                isUploaded:
                                    _photo.uploadStatus ==
                                    UploadStatus.uploaded,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _imageIdTile(_photo.id),
                      const SizedBox(height: 10),
                      _metaTile(Icons.event, 'Captured', captured),
                      if (canStoreLocally) ...[
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _restoring ? null : _storeLocally,
                            icon: _restoring
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                              _restoring
                                  ? 'Storing locally...'
                                  : 'Store Local Copy',
                            ),
                          ),
                        ),
                      ],
                      if (_photo.uploadStatus == UploadStatus.pending) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _deletingPending
                                ? null
                                : _stopUploadAndDeletePending,
                            icon: _deletingPending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_forever_rounded),
                            label: Text(
                              _deletingPending
                                  ? 'Deleting...'
                                  : 'Stop Upload & Delete Local',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPanel(
    bool hasLocalFile,
    bool isLocalAvif,
    File localFile,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.9),
          child: hasLocalFile
              ? (isLocalAvif
                    ? _zoomablePreview(
                        AvifImage.file(
                          localFile,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      )
                    : _zoomablePreview(
                        Image.file(
                          localFile,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ))
              : FutureBuilder<Uint8List?>(
                  future: _cloudBytesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cloudBytes = snapshot.data;
                    if (cloudBytes == null || cloudBytes.isEmpty) {
                      final message = AppConfig.hasAwsCredentials
                          ? 'Cloud image not accessible. Verify S3 object key and IAM policy.'
                          : 'Cloud image not accessible. Private S3 requires AWS credentials via --dart-define.';
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }

                    return _zoomablePreview(
                      AvifImage.memory(
                        cloudBytes,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Text(
                            'Image not available.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _zoomablePreview(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) {
            _doubleTapDetails = details;
          },
          onDoubleTap: _toggleZoomAtTap,
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _zoomController,
                minScale: 1,
                maxScale: 5,
                panEnabled: true,
                scaleEnabled: true,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(120),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Center(child: child),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _zoomController,
                  builder: (context, matrix, _) {
                    final zoomed = matrix.getMaxScaleOnAxis() > 1.01;
                    if (!zoomed) {
                      return const SizedBox.shrink();
                    }
                    return FloatingActionButton.small(
                      heroTag: 'previewZoomReset',
                      onPressed: _resetZoom,
                      tooltip: 'Reset zoom',
                      child: const Icon(Icons.center_focus_strong),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleZoomAtTap() {
    final currentScale = _zoomController.value.getMaxScaleOnAxis();
    if (currentScale > 1.01) {
      _resetZoom();
      return;
    }

    final details = _doubleTapDetails;
    if (details == null) {
      return;
    }

    const targetScale = 2.5;
    final position = details.localPosition;
    _zoomController.value = Matrix4.identity()
      ..translate(
        -position.dx * (targetScale - 1),
        -position.dy * (targetScale - 1),
      )
      ..scale(targetScale);
  }

  void _resetZoom() {
    _zoomController.value = Matrix4.identity();
  }

  Widget _sourceChip({required bool hasLocalFile, required bool isUploaded}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _indicatorIcon(
            icon: Icons.phone_android_rounded,
            active: hasLocalFile,
            activeColor: Colors.lightBlue.shade700,
          ),
          const SizedBox(width: 6),
          _indicatorIcon(
            icon: Icons.cloud_rounded,
            active: isUploaded,
            activeColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _indicatorIcon({
    required IconData icon,
    required bool active,
    required Color activeColor,
  }) {
    return Icon(icon, size: 14, color: active ? activeColor : Colors.black45);
  }

  Widget _metaTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageIdTile(String imageId) {
    return Row(
      children: [
        Expanded(child: _metaTile(Icons.fingerprint, 'Image ID', imageId)),
        IconButton(
          tooltip: 'Copy image ID',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: imageId));
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Image ID copied')));
          },
          icon: const Icon(Icons.copy_rounded),
        ),
      ],
    );
  }
}
