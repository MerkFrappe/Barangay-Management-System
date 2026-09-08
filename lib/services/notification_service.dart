import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/app_notification.dart';
import '../screens/residence_announcements.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  NotificationService._();

  static final _firestore = FirebaseFirestore.instance;
  static bool _oneSignalConfigured = false;
  static bool _listenersRegistered = false;
  static String? _lastSyncedUid;

  static String get _oneSignalAppId =>
      const String.fromEnvironment('ONESIGNAL_APP_ID');

  static Future<void> initialize() async {
    if (kIsWeb || _oneSignalAppId.isEmpty || _oneSignalConfigured) return;

    OneSignal.initialize(_oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);
    _registerOneSignalListeners();
    _oneSignalConfigured = true;
  }

  static void _registerOneSignalListeners() {
    if (_listenersRegistered) return;
    _listenersRegistered = true;

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });
    OneSignal.Notifications.addClickListener((event) {
      final data =
          event.notification.additionalData ?? const <String, dynamic>{};
      if (data['type'] == 'announcement' &&
          appNavigatorKey.currentState != null) {
        appNavigatorKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const CivicHorizonApp()),
        );
      }
    });
  }

  static Future<void> syncUser(User user, String role) async {
    if (kIsWeb || _oneSignalAppId.isEmpty) return;
    if (_lastSyncedUid == user.uid) return;
    await initialize();
    await OneSignal.login(user.uid);
    await OneSignal.User.addTags({'role': role});
    _lastSyncedUid = user.uid;
  }

  static Stream<List<AppNotification>> streamForUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map(AppNotification.fromDocument)
              .toList();
          notifications.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
          return notifications;
        });
  }

  static Future<void> markRead(String uid, String notificationId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true})
        .then((_) async {
          final unread = await _firestore
              .collection('users')
              .doc(uid)
              .collection('notifications')
              .where('isRead', isEqualTo: false)
              .limit(1)
              .get();
          await _firestore.collection('users').doc(uid).set({
            'hasUnreadNotifications': unread.docs.isNotEmpty,
            if (unread.docs.isEmpty) 'notification.isRead': true,
          }, SetOptions(merge: true));
        });
  }

  static const _adminRoles = [
    'Admin',
    'Chairman',
    'Secretary',
    'Treasurer',
    'Auditor',
    'Kagawad',
    'SK Chairman',
    'Tanod',
    'BHW',
    'Admin Staff',
  ];

  static Future<void> notifyResidents({
    required String notificationId,
    required String type,
    required String referenceId,
    required String title,
    required String body,
  }) => _notifyUsers(
    roles: const ['Resident'],
    notificationId: notificationId,
    type: type,
    referenceId: referenceId,
    title: title,
    body: body,
  );

  static Future<void> notifyAdmins({
    required String notificationId,
    required String type,
    required String referenceId,
    required String title,
    required String body,
  }) => _notifyUsers(
    roles: _adminRoles,
    notificationId: notificationId,
    type: type,
    referenceId: referenceId,
    title: title,
    body: body,
  );

  static Future<void> notifyUser({
    required String uid,
    required String notificationId,
    required String type,
    required String referenceId,
    required String title,
    required String body,
  }) => _writeNotification(
    user: _firestore.collection('users').doc(uid),
    notificationId: notificationId,
    type: type,
    referenceId: referenceId,
    title: title,
    body: body,
  );

  static Future<void> _notifyUsers({
    required List<String> roles,
    required String notificationId,
    required String type,
    required String referenceId,
    required String title,
    required String body,
  }) async {
    final users = await Future.wait(
      roles.map(
        (role) =>
            _firestore.collection('users').where('role', isEqualTo: role).get(),
      ),
    );
    final recipients = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    for (final snapshot in users) {
      for (final user in snapshot.docs) {
        recipients[user.id] = user;
      }
    }
    final recipientDocs = recipients.values.toList();
    for (var offset = 0; offset < recipientDocs.length; offset += 500) {
      final batch = _firestore.batch();
      for (final user in recipientDocs.skip(offset).take(500)) {
        final notificationRef = user.reference.collection('notifications').doc(notificationId);
        final notification = {
          'type': type,
          'referenceId': referenceId,
          'title': title,
          'body': body,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
        batch.set(notificationRef, notification, SetOptions(merge: true));
        batch.set(user.reference, {
          'notification': {
            'type': type,
            'referenceId': referenceId,
            'title': title,
            'body': body,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          },
          'hasUnreadNotifications': true,
        }, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  static Future<void> _writeNotification({
    required DocumentReference<Map<String, dynamic>> user,
    required String notificationId,
    required String type,
    required String referenceId,
    required String title,
    required String body,
  }) async {
    final notification = {
      'type': type,
      'referenceId': referenceId,
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final batch = _firestore.batch();
    batch.set(
      user.collection('notifications').doc(notificationId),
      notification,
      SetOptions(merge: true),
    );
    batch.set(user, {
      'notification': notification,
      'hasUnreadNotifications': true,
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
