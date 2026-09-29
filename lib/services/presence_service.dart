import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

/// Publishes an authenticated user's location only while the app is active and
/// the user has granted location permission. Entries are treated as offline by
/// the dashboard when no heartbeat has arrived for two minutes.
class PresenceService {
  PresenceService._();

  static Timer? _heartbeat;
  static String? _activeUid;
  static String? _activeRole;

  static Future<void> start(User user, String role) async {
    if (_activeUid != user.uid) {
      _heartbeat?.cancel();
      _activeUid = user.uid;
    }
    _activeRole = role;
    await _publish();
    _heartbeat ??= Timer.periodic(
      const Duration(seconds: 45),
      (_) => _publish(),
    );
  }

  static Future<void> stop() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    final uid = _activeUid;
    _activeUid = null;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('live_presence')
          .doc(uid)
          .delete()
          .catchError((_) {});
    }
  }

  static Future<void> _publish() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = _activeUid;
    if (user == null || uid == null || user.uid != uid) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = userDoc.data() ?? const <String, dynamic>{};
      final name =
          (data['dashboardDisplayName'] ??
                  data['displayName'] ??
                  data['accountName'] ??
                  user.displayName ??
                  user.email ??
                  'User')
              .toString();

      await FirebaseFirestore.instance
          .collection('live_presence')
          .doc(uid)
          .set({
            'userId': uid,
            'displayName': name,
            'role': _activeRole ?? data['role'] ?? 'Resident',
            'location': GeoPoint(position.latitude, position.longitude),
            'lastActiveAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {
      // A location/network failure must never block normal app use.
    }
  }
}
