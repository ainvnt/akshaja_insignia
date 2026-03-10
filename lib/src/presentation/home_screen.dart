import 'dart:async';
import 'dart:io';

import 'package:akshaja_insignia/src/domain/photo_record.dart';
import 'package:akshaja_insignia/src/presentation/camera_capture_screen.dart';
import 'package:akshaja_insignia/src/presentation/date_folder_gallery_screen.dart';
import 'package:akshaja_insignia/src/presentation/models/date_folder_group.dart';
import 'package:akshaja_insignia/src/presentation/profile_screen.dart';
import 'package:akshaja_insignia/src/presentation/widgets/date_folder_tile.dart';
import 'package:akshaja_insignia/src/presentation/widgets/home_summary_card.dart';
import 'package:akshaja_insignia/src/repositories/photo_repository.dart';
import 'package:akshaja_insignia/src/services/auto_refresh_memory_service.dart';
import 'package:akshaja_insignia/src/services/auth_ui_state_service.dart';
import 'package:akshaja_insignia/src/services/network_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final PhotoRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<void>? _changesSubscription;
  StreamSubscription<bool>? _networkSubscription;
  final NetworkService _networkService = NetworkService();

  bool _loading = true;
  bool _isOnline = true;
  int _pendingUploadCount = 0;
  bool _autoRefreshEnabled = false;
  bool _autoRefreshInProgress = false;
  Duration _autoRefreshInterval = const Duration(hours: 1);
  Timer? _autoRefreshTimer;
  String? _errorText;
  List<PhotoRecord> _photos = const <PhotoRecord>[];
  int? _cloudTotalPhotos;
  DateTimeRange? _activeSyncRange;

  bool get _lockAllActions => !_isOnline && _pendingUploadCount > 0;

  static const List<Duration> _autoRefreshOptions = <Duration>[
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 3),
    Duration(hours: 5),
  ];

  DateTimeRange _currentWeekRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final clampedEnd = endOfWeek.isAfter(today) ? today : endOfWeek;
    return DateTimeRange(start: startOfWeek, end: clampedEnd);
  }

  @override
  void initState() {
    super.initState();
    _autoRefreshEnabled = AutoRefreshMemoryService.enabled;
    _autoRefreshInterval = AutoRefreshMemoryService.interval;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (AuthUiStateService.consumeLoginSuccessForHome()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful. Welcome back!')),
        );
      }
    });
    _activeSyncRange = _currentWeekRange(DateTime.now());
    unawaited(_initializeNetworkState());
    _networkSubscription = _networkService.onStatusChanged.listen((isOnline) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isOnline = isOnline;
      });
    });
    _changesSubscription = widget.repository.changes.listen((_) {
      unawaited(_loadPhotos());
    });
    _restartAutoRefreshTimer();
    unawaited(_initializeScreen());
  }

  Future<void> _initializeNetworkState() async {
    final isOnline = await _networkService.isOnline();
    if (!mounted) {
      return;
    }
    setState(() {
      _isOnline = isOnline;
    });
  }

  void _restartAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    if (!_autoRefreshEnabled) {
      return;
    }

    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      unawaited(_runAutoRefreshTick());
    });
  }

  void _setAutoRefreshEnabled(bool enabled) {
    setState(() {
      _autoRefreshEnabled = enabled;
    });
    AutoRefreshMemoryService.save(
      isEnabled: _autoRefreshEnabled,
      every: _autoRefreshInterval,
    );
    _restartAutoRefreshTimer();
  }

  Future<void> _runAutoRefreshTick() async {
    if (!mounted || !_autoRefreshEnabled) {
      return;
    }
    if (_autoRefreshInProgress || !_isOnline || _lockAllActions) {
      return;
    }

    _autoRefreshInProgress = true;
    try {
      await widget.repository.syncPending();
      final range = _activeSyncRange;
      await widget.repository.syncFromCloudToLocalDateFolders(
        startDate: range?.start,
        endDate: range?.end,
        clearOnEmpty: false,
      );
      await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);
    } catch (error) {
      if (_isConnectivityError(error)) {
        _setOfflineMode();
      }
    } finally {
      _autoRefreshInProgress = false;
    }
  }

  Future<void> _showAutoRefreshSettings() async {
    if (!mounted) {
      return;
    }

    var enabled = _autoRefreshEnabled;
    var selectedInterval = _autoRefreshInterval;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile.adaptive(
                      value: enabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto refresh'),
                      subtitle: const Text(
                        'Automatically sync photos from cloud',
                      ),
                      onChanged: (value) {
                        setSheetState(() {
                          enabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('Refresh interval'),
                    const SizedBox(height: 6),
                    for (final option in _autoRefreshOptions)
                      RadioListTile<Duration>(
                        value: option,
                        groupValue: selectedInterval,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_autoRefreshLabel(option)),
                        onChanged: enabled
                            ? (value) {
                                if (value == null) {
                                  return;
                                }
                                setSheetState(() {
                                  selectedInterval = value;
                                });
                              }
                            : null,
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved != true || !mounted) {
      return;
    }

    setState(() {
      _autoRefreshEnabled = enabled;
      _autoRefreshInterval = selectedInterval;
    });
    AutoRefreshMemoryService.save(
      isEnabled: _autoRefreshEnabled,
      every: _autoRefreshInterval,
    );
    _restartAutoRefreshTimer();
  }

  String _autoRefreshLabel(Duration duration) {
    if (duration.inMinutes == 30) {
      return 'Every 30 minutes';
    }
    if (duration.inHours == 1) {
      return 'Every 1 hour';
    }
    return 'Every ${duration.inHours} hours';
  }

  Widget _buildInlineAutoRefreshToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _showAutoRefreshSettings,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'Auto',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Switch.adaptive(
          value: _autoRefreshEnabled,
          onChanged: _setAutoRefreshEnabled,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Future<void> _initializeScreen() async {
    try {
      await _loadPhotos();
      if (_isOnline) {
        try {
          await widget.repository.syncPending();
          await _loadCloudCount();
        } catch (error) {
          if (_isConnectivityError(error)) {
            _setOfflineMode();
          } else {
            rethrow;
          }
        }
      } else {
        _cloudTotalPhotos = null;
      }
    } catch (error) {
      if (_isConnectivityError(error)) {
        _setOfflineMode();
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Failed to load photos: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadPhotos() async {
    final records = await widget.repository.getAllPhotos();
    final pendingCount = records
        .where((photo) => photo.uploadStatus == UploadStatus.pending)
        .length;
    final visibleRecords = records
        .where(_isWithinActiveDateRange)
        .toList(growable: false);
    final sorted = <PhotoRecord>[...visibleRecords]
      ..sort((a, b) {
        final folderA = _dateFolderKey(a.filePath);
        final folderB = _dateFolderKey(b.filePath);
        final folderCompare = folderB.compareTo(folderA);
        if (folderCompare != 0) {
          return folderCompare;
        }
        return b.capturedAt.compareTo(a.capturedAt);
      });

    if (!mounted) {
      return;
    }
    setState(() {
      _photos = sorted;
      _pendingUploadCount = pendingCount;
    });
  }

  Future<void> _loadCloudCount() async {
    try {
      final cloudCount = await widget.repository.getCloudPhotoCount();
      if (!mounted) {
        return;
      }
      setState(() {
        _cloudTotalPhotos = cloudCount;
      });
    } on SocketException {
      _setOfflineMode();
    } catch (_) {
      // Keep local UI usable if cloud count fails for any reason.
      if (!mounted) {
        return;
      }
      setState(() {
        _cloudTotalPhotos = null;
      });
    }
  }

  void _setOfflineMode() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isOnline = false;
      _cloudTotalPhotos = null;
    });
  }

  bool _isConnectivityError(Object error) {
    final message = error.toString().toLowerCase();
    return error is SocketException ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated with hostname');
  }

  String _dateFolderKey(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final marker = '/photos/';
    final markerIndex = normalized.lastIndexOf(marker);

    if (markerIndex == -1) {
      return '';
    }

    final afterPhotos = normalized.substring(markerIndex + marker.length);
    final parts = afterPhotos.split('/');
    if (parts.length < 4) {
      return '';
    }

    return '${parts[0]}/${parts[1]}/${parts[2]}';
  }

  String _directoryLabel(PhotoRecord photo) {
    final key = _dateFolderKey(photo.filePath);
    if (key.isNotEmpty) {
      return key;
    }
    return DateFormat('yyyy/MM/dd').format(photo.capturedAt.toLocal());
  }

  bool _isWithinActiveDateRange(PhotoRecord photo) {
    final range = _activeSyncRange;
    if (range == null) {
      return true;
    }

    final key = _dateFolderKey(photo.filePath);
    if (key.isNotEmpty) {
      final parts = key.split('/');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          final folderDate = DateTime(year, month, day);
          return !folderDate.isBefore(range.start) &&
              !folderDate.isAfter(range.end);
        }
      }
    }

    final localCaptureDate = DateTime(
      photo.capturedAt.toLocal().year,
      photo.capturedAt.toLocal().month,
      photo.capturedAt.toLocal().day,
    );
    return !localCaptureDate.isBefore(range.start) &&
        !localCaptureDate.isAfter(range.end);
  }

  Future<bool> _shouldBlockCloudPull() async {
    final pendingCount = await widget.repository.getPendingUploadCount();
    if (pendingCount <= 0) {
      return false;
    }

    if (!mounted) {
      return true;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload in progress'),
        content: Text(
          'Cannot run pull-down refresh or cloud sync while '
          '$pendingCount file(s) are pending upload. '
          'Please upload pending files first.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return true;
  }

  Future<void> _syncPendingPhotos() async {
    if (!_isOnline) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Sync is disabled.'),
        ),
      );
      return;
    }

    final syncConfirmed = await _confirmCloudReload(
      title: 'Sync from cloud?',
      message:
          'This will upload pending local items and pull latest cloud data for your current date range.',
      actionLabel: 'Sync Now',
    );
    if (!syncConfirmed) {
      return;
    }

    try {
      await widget.repository.syncPending();
      final range = _activeSyncRange;
      final imported = await widget.repository.syncFromCloudToLocalDateFolders(
        startDate: range?.start,
        endDate: range?.end,
        clearOnEmpty: false,
      );
      await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);
      if (!mounted) {
        return;
      }
      final message = imported > 0
          ? (range == null
                ? 'Sync complete. Imported $imported cloud item(s). Thumbnails load on demand.'
                : 'Sync complete for selected range. Imported $imported cloud item(s).')
          : (range == null
                ? 'Sync complete.'
                : 'Sync complete. No new cloud items in selected range.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (_isConnectivityError(error)) {
        _setOfflineMode();
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync failed: $error')));
    }
  }

  Future<void> _refreshHomeScreen() async {
    if (!_isOnline) {
      return;
    }

    if (await _shouldBlockCloudPull()) {
      return;
    }

    final refreshConfirmed = await _confirmCloudReload(
      title: 'Refresh from cloud?',
      message:
          'This will pull latest data from cloud. '
          '${_activeSyncRange != null ? 'Existing local files for the selected range will be cleared before reload.' : 'Local data may be refreshed based on cloud state.'}',
      actionLabel: 'Refresh',
    );
    if (!refreshConfirmed) {
      return;
    }

    try {
      await widget.repository.syncPending();
      final range = _activeSyncRange;
      if (range == null) {
        await widget.repository.syncFromCloudToLocalDateFolders();
      } else {
        await widget.repository.clearAllLocalData();
        await widget.repository.syncFromCloudToLocalDateFolders(
          startDate: range.start,
          endDate: range.end,
          clearOnEmpty: false,
        );
      }
      await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);
    } catch (error) {
      if (_isConnectivityError(error)) {
        _setOfflineMode();
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reload failed: $error')));
    }
  }

  Future<void> _syncByDateRange() async {
    if (!_isOnline) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Sync is disabled.'),
        ),
      );
      return;
    }

    if (await _shouldBlockCloudPull()) {
      return;
    }

    final syncConfirmed = await _confirmCloudReload(
      title: 'Sync from cloud?',
      message:
          'This will clear current local data and reload photos from cloud for the selected date range.',
      actionLabel: 'Continue Sync',
    );
    if (!syncConfirmed) {
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final defaultRange = _currentWeekRange(now);
    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDateRange: _activeSyncRange ?? defaultRange,
      helpText: 'Select Cloud Sync Range',
      saveText: 'Sync',
    );

    if (selectedRange == null) {
      return;
    }

    try {
      _activeSyncRange = selectedRange;
      imageCache.clear();
      imageCache.clearLiveImages();
      await widget.repository.clearAllLocalData();
      final imported = await widget.repository.syncFromCloudToLocalDateFolders(
        startDate: selectedRange.start,
        endDate: selectedRange.end,
        clearOnEmpty: false,
      );
      await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);

      if (!mounted) {
        return;
      }

      final startLabel = DateFormat('yyyy-MM-dd').format(selectedRange.start);
      final endLabel = DateFormat('yyyy-MM-dd').format(selectedRange.end);
      final message = imported > 0
          ? 'Loaded $imported item(s) for $startLabel to $endLabel.'
          : 'No cloud data found for $startLabel to $endLabel.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (_isConnectivityError(error)) {
        _setOfflineMode();
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Date-range sync failed: $error')));
    }
  }

  Future<void> _openCamera() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CameraCaptureScreen(repository: widget.repository),
      ),
    );

    if (saved == true) {
      await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);
    }
  }

  void _openDateFolder(DateFolderGroup folder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DateFolderGalleryScreen(
          dateKey: folder.key,
          photos: folder.photos,
          repository: widget.repository,
        ),
      ),
    );
  }

  Future<void> _deleteFolderLocalCopies(DateFolderGroup folder) async {
    final localCount = folder.photos
        .where((photo) => File(photo.filePath).existsSync())
        .length;
    if (localCount == 0) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No local files found in this folder. Items may be cloud-only.',
          ),
        ),
      );
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete local files in ${folder.key.replaceAll('/', '-')}?',
            ),
            content: Text(
              'This will delete $localCount local file(s) '
              'from ${folder.photos.length} image(s). '
              'Cloud copies will remain available.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final deletedCount = await widget.repository.deleteLocalCopiesForDateFolder(
      folder.key,
      folder.photos,
    );

    await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted $deletedCount local file(s).')),
    );
  }

  Future<void> _deleteFolderData(DateFolderGroup folder) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete folder ${folder.key.replaceAll('/', '-')}?'),
            content: Text(
              'This will remove ${folder.photos.length} item(s) from local storage '
              'and from the app list for this folder.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final deletedLocalCount = await widget.repository.deletePhotos(
      folder.photos,
      deleteLocalFiles: true,
    );
    await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Folder deleted. Removed ${folder.photos.length} record(s), '
          '$deletedLocalCount local file(s).',
        ),
      ),
    );
  }

  Future<void> _deleteAllFoldersData() async {
    if (_photos.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No folders to delete.')));
      return;
    }

    final folderCount = _buildDateFolders().length;
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete all folders?'),
            content: Text(
              'This will remove all $folderCount folder(s) and ${_photos.length} record(s) '
              'from the app list and local storage.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete All'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final recordsToDelete = List<PhotoRecord>.from(_photos);
    final deletedLocalCount = await widget.repository.deletePhotos(
      recordsToDelete,
      deleteLocalFiles: true,
    );
    await Future.wait<void>(<Future<void>>[_loadPhotos(), _loadCloudCount()]);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted all folders. Removed ${recordsToDelete.length} record(s), '
          '$deletedLocalCount local file(s).',
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_changesSubscription?.cancel());
    unawaited(_networkSubscription?.cancel());
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tonedIconColor = colorScheme.primary.withValues(alpha: 0.78);
    final tonedDisabledIconColor = colorScheme.onSurface.withValues(
      alpha: 0.35,
    );
    final blendedPrimary = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      colorScheme.surface,
    );
    final blendedSecondary = Color.alphaBlend(
      colorScheme.secondary.withValues(alpha: 0.1),
      colorScheme.surface,
    );
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Akshaja Insignia'),
        centerTitle: true,
        leading: IconButton(
          style: IconButton.styleFrom(
            foregroundColor: tonedIconColor,
            disabledForegroundColor: tonedDisabledIconColor,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            );
          },
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: 'Profile',
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              foregroundColor: tonedIconColor,
              disabledForegroundColor: tonedDisabledIconColor,
            ),
            onPressed: _isOnline ? _deleteAllFoldersData : null,
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: _isOnline
                ? 'Delete all folders'
                : 'Offline: delete disabled',
          ),
          IconButton(
            style: IconButton.styleFrom(
              foregroundColor: tonedIconColor,
              disabledForegroundColor: tonedDisabledIconColor,
            ),
            onPressed: (_isOnline && !_lockAllActions)
                ? _syncByDateRange
                : null,
            icon: const Icon(Icons.date_range_rounded),
            tooltip: _isOnline
                ? (_lockAllActions
                      ? 'Offline with pending uploads: action disabled'
                      : 'Sync cloud by date range')
                : 'Offline: sync disabled',
          ),
          IconButton(
            style: IconButton.styleFrom(
              foregroundColor: tonedIconColor,
              disabledForegroundColor: tonedDisabledIconColor,
            ),
            onPressed: (_isOnline && !_lockAllActions)
                ? _syncPendingPhotos
                : null,
            icon: const Icon(Icons.sync),
            tooltip: _isOnline
                ? (_lockAllActions
                      ? 'Offline with pending uploads: action disabled'
                      : 'Sync pending uploads')
                : 'Offline: sync disabled',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface, blendedPrimary, blendedSecondary],
          ),
        ),
        child: _wrapWithOfflineBanner(_buildBody()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.primary,
        onPressed: _openCamera,
        tooltip: 'Open camera',
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Capture'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null && _photos.isEmpty) {
      return _buildRefreshContainer(
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.error_outline, size: 34),
            const SizedBox(height: 10),
            Text(_errorText!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isOnline
                  ? () {
                      setState(() {
                        _loading = true;
                        _errorText = null;
                      });
                      unawaited(_initializeScreen());
                    }
                  : null,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final folders = _buildDateFolders();

    if (folders.isEmpty) {
      final pendingCount = _photos
          .where((photo) => photo.uploadStatus == UploadStatus.pending)
          .length;
      final uploadedForSummary = _cloudTotalPhotos ?? 0;
      final totalForSummary = uploadedForSummary + pendingCount;
      final uploadedLabel = _cloudTotalPhotos != null ? 'Cloud' : 'Uploaded';
      return _buildRefreshContainer(
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            HomeSummaryCard(
              totalPhotos: totalForSummary,
              uploadedPhotos: uploadedForSummary,
              pendingPhotos: pendingCount,
              uploadedLabel: uploadedLabel,
              infoText: _dateRangeLabel(),
              infoTrailing: _buildInlineAutoRefreshToggle(),
              rangePhotos: _photos.length,
            ),
            SizedBox(height: 20),
            const Center(child: Text('No date folders found.')),
          ],
        ),
      );
    }

    final uploadedCount = _photos
        .where((photo) => photo.uploadStatus == UploadStatus.uploaded)
        .length;
    final pendingCount = _photos
        .where((photo) => photo.uploadStatus == UploadStatus.pending)
        .length;
    final uploadedForSummary = (_cloudTotalPhotos != null)
        ? (_cloudTotalPhotos! > uploadedCount
              ? _cloudTotalPhotos!
              : uploadedCount)
        : uploadedCount;
    final totalForSummary = uploadedForSummary + pendingCount;
    final uploadedLabel = _cloudTotalPhotos != null ? 'Cloud' : 'Uploaded';

    return _buildRefreshContainer(
      ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: folders.length + 1,
        separatorBuilder: (_, index) => index == 0
            ? const SizedBox(height: 14)
            : const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return HomeSummaryCard(
              totalPhotos: totalForSummary,
              uploadedPhotos: uploadedForSummary,
              pendingPhotos: pendingCount,
              uploadedLabel: uploadedLabel,
              infoText: _dateRangeLabel(),
              infoTrailing: _buildInlineAutoRefreshToggle(),
              rangePhotos: _photos.length,
            );
          }

          final folder = folders[index - 1];
          final hasCloudBackedPhoto = folder.photos.any(
            (photo) => photo.uploadStatus == UploadStatus.uploaded,
          );
          return DateFolderTile(
            folder: folder,
            enabled: !_lockAllActions,
            menuEnabled: !_lockAllActions && hasCloudBackedPhoto,
            onDeleteLocal: _lockAllActions
                ? () {}
                : () => _deleteFolderLocalCopies(folder),
            onDeleteFolder: _lockAllActions
                ? () {}
                : () => _deleteFolderData(folder),
            onOpen: _lockAllActions ? () {} : () => _openDateFolder(folder),
          );
        },
      ),
    );
  }

  Widget _buildRefreshContainer(Widget child) {
    if (!_isOnline) {
      return child;
    }

    return RefreshIndicator(onRefresh: _refreshHomeScreen, child: child);
  }

  Widget _wrapWithOfflineBanner(Widget child) {
    if (_isOnline) {
      return child;
    }

    final lockAllActions = _pendingUploadCount > 0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lockAllActions
                      ? 'Offline with pending uploads: all actions are disabled until upload can resume.'
                      : 'Offline mode: refresh and sync are disabled.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Future<bool> _confirmCloudReload({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    if (!mounted) {
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  List<DateFolderGroup> _buildDateFolders() {
    final folderMap = <String, List<PhotoRecord>>{};
    for (final photo in _photos) {
      final key = _directoryLabel(photo);
      folderMap.putIfAbsent(key, () => <PhotoRecord>[]).add(photo);
    }

    final keys = folderMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return keys
        .map(
          (key) => DateFolderGroup(
            key: key,
            photos: folderMap[key] ?? const <PhotoRecord>[],
          ),
        )
        .toList();
  }

  String _dateRangeLabel() {
    final range = _activeSyncRange;
    if (range == null) {
      return 'Date Range: All dates';
    }

    final startLabel = DateFormat('yyyy-MM-dd').format(range.start);
    final endLabel = DateFormat('yyyy-MM-dd').format(range.end);
    return 'Date Range: $startLabel to $endLabel';
  }
}
