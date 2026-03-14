import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  const AppUpdateInfo({required this.available, this.message});

  final bool available;

  /// Optional changelog / headline supplied from Firestore.
  final String? message;
}

/// Checks Firestore document `config/app_version` for a newer build.
///
/// Expected Firestore document fields:
///   latestBuildNumber  (integer) – the latest published build number
///   updateMessage      (string, optional) – short changelog shown in banner
///
/// Returns [AppUpdateInfo.available] == false on any error so the banner
/// is never shown due to a connectivity or config issue.
class UpdateService {
  const UpdateService._();

  static Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_version')
          .get();

      if (!doc.exists) return const AppUpdateInfo(available: false);

      final data = doc.data()!;
      final latestBuild =
          (data['latestBuildNumber'] as num?)?.toInt() ?? 0;
      final message = data['updateMessage'] as String?;

      return AppUpdateInfo(
        available: latestBuild > currentBuild,
        message: message,
      );
    } catch (_) {
      // Non-critical: silently ignore all errors (offline, missing doc, etc.)
      return const AppUpdateInfo(available: false);
    }
  }
}
