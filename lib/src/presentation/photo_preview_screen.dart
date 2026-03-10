import 'dart:io';
import 'dart:typed_data';

import 'package:akshaja_insignia/src/domain/photo_draft.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/services/watermark_service.dart';
import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatefulWidget {
  const PhotoPreviewScreen({
    super.key,
    required this.draft,
    required this.repository,
  });

  final PhotoDraft draft;
  final PhotoRepository repository;

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final WatermarkService _watermarkService = const WatermarkService();
  bool _saving = false;
  Future<Uint8List>? _stampedPreviewBytesFuture;

  @override
  void initState() {
    super.initState();
    _stampedPreviewBytesFuture = _buildStampedPreview();
  }

  Future<Uint8List> _buildStampedPreview() async {
    final bytes = await File(widget.draft.tempFilePath).readAsBytes();
    final stamped = _watermarkService.stampPhoto(
      sourceBytes: bytes,
      capturedAt: widget.draft.capturedAt,
      latitude: widget.draft.latitude,
      longitude: widget.draft.longitude,
    );
    return Uint8List.fromList(stamped);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    try {
      await widget.repository.saveDraft(widget.draft);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(' Failed to save photo: $error')));
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Uint8List>(
              future: _stampedPreviewBytesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Image.file(
                    File(widget.draft.tempFilePath),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () {
                            Navigator.of(context).pop(false);
                          },
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
