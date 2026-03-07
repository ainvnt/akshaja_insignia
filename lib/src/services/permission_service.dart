import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService();

  Future<bool> requestCapturePermissions() async {
    final permissions = <Permission>[
      Permission.camera,
      Permission.locationWhenInUse,
      if (Platform.isIOS) Permission.photos,
      if (Platform.isAndroid) ...<Permission>[
        Permission.storage,
        Permission.photos,
      ],
    ];

    final statuses = await permissions.request();

    final cameraGranted = _isGranted(statuses[Permission.camera]);
    final locationGranted = _isGranted(statuses[Permission.locationWhenInUse]) ||
        _isGranted(statuses[Permission.location]);

    final mediaPermissions = Platform.isIOS
        ? <Permission>[Permission.photos]
        : <Permission>[Permission.storage, Permission.photos];
    final mediaGranted = mediaPermissions.any(
      (permission) => _isGranted(statuses[permission]),
    );

    return cameraGranted && locationGranted && mediaGranted;
  }

  bool _isGranted(PermissionStatus? status) {
    if (status == null) {
      return false;
    }
    return status.isGranted || status.isLimited;
  }
}
