import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationProfileService {
  RegistrationProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const int schemaVersion = 1;

  final FirebaseFirestore _firestore;

  Future<void> saveUserProfile({
    required User user,
    required String registrationMethod,
    required bool isNewUser,
    String? displayName,
    String? mobile,
  }) async {
    final now = FieldValue.serverTimestamp();
    final sanitizedMobile = _sanitizeMobile(mobile ?? user.phoneNumber);
    final sanitizedDisplayName = _sanitizeDisplayName(
      displayName ?? user.displayName,
    );

    final payload = <String, Object?>{
      'schemaVersion': schemaVersion,
      'uid': user.uid,
      'displayName': sanitizedDisplayName,
      'email': user.email,
      'mobile': sanitizedMobile,
      'registrationMethod': registrationMethod,
      if (isNewUser) 'createdAt': now,
      'lastLoginAt': now,
      'updatedAt': now,
    }..removeWhere((_, value) => value == null);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(payload, SetOptions(merge: true));
  }

  String? _sanitizeMobile(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _sanitizeDisplayName(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
