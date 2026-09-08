import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../screens/residence_announcements.dart';
import '../screens/document_tracker_screen.dart';
import '../screens/admin_documentRequest.dart';
import '../screens/emergency_broadcast_screen.dart';

class NotificationBell extends StatelessWidget {
  final bool isAdmin;

  const NotificationBell({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<List<AppNotification>>(
      stream: NotificationService.streamForUser(uid),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? const <AppNotification>[];
        final unreadCount = notifications.where((item) => !item.isRead).length;
        return IconButton(
          splashRadius: 22,
          tooltip: 'Notifications',
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          onPressed: () => _showInbox(context, uid, notifications),
        );
      },
    );
  }

  Future<void> _showInbox(
    BuildContext context,
    String uid,
    List<AppNotification> notifications,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(sheetContext).height * .7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Notifications',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(child: Text('No notifications yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              leading: Icon(
                                notification.type == 'announcement'
                                    ? Icons.campaign_outlined
                                    : Icons.notifications_outlined,
                                color: notification.isRead
                                    ? AppColors.outline
                                    : AppColors.primary,
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(notification.body),
                              onTap: () async {
                                await NotificationService.markRead(
                                  uid,
                                  notification.id,
                                );
                                if (!sheetContext.mounted) return;
                                Navigator.pop(sheetContext);
                                if (context.mounted) {
                                  final destination = switch (notification
                                      .type) {
                                    'announcement' => const CivicHorizonApp(),
                                    'document_status' =>
                                      const DocumentTrackerScreen(),
                                    'document_request' =>
                                      const AdminDocumentRequestScreen(),
                                    'emergency_report' =>
                                      const EmergencyBroadcastScreen(),
                                    _ => null,
                                  };
                                  if (destination == null ||
                                      (!isAdmin &&
                                          (notification.type ==
                                                  'document_request' ||
                                              notification.type ==
                                                  'emergency_report')) ||
                                      (isAdmin &&
                                          notification.type ==
                                              'document_status')) {
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => destination,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
