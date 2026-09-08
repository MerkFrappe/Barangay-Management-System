import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';

class TopNavigationBar extends StatelessWidget {
  final VoidCallback? onSwitchPortal;
  const TopNavigationBar({super.key, this.onSwitchPortal});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          //---------------------------------------
          // Drawer Button (Mobile)
          //---------------------------------------
          if (!desktop)
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    color: AppColors.primary,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
            ),

          //---------------------------------------
          // Search Bar
          //---------------------------------------
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search services, news, or guidelines...",
                  hintStyle: AppTextStyles.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          //---------------------------------------
          // Notification Button
          //---------------------------------------
          const _ResidentNotificationButton(),

          const SizedBox(width: 12),

          //---------------------------------------
          // Divider
          //---------------------------------------
          if (desktop)
            Container(width: 1, height: 36, color: AppColors.outlineVariant),

          if (desktop) const SizedBox(width: 18),

          //---------------------------------------
          // User Info
          //---------------------------------------
          if (desktop)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Juan Dela Cruz",
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Resident ID: #2024-8892",
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),

          if (desktop) const SizedBox(width: 14),

          //---------------------------------------
          // Avatar
          //---------------------------------------
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              "JD",
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentNotificationButton extends StatelessWidget {
  const _ResidentNotificationButton();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Icon(
        Icons.notifications_none_rounded,
        color: AppColors.onSurfaceVariant,
      );
    }

    final stream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final notifications = snapshot.data?.docs ?? [];
        final unread =
            notifications.where((doc) => doc.data()['isRead'] != true).length;
        return Badge(
          isLabelVisible: unread > 0,
          label: Text('$unread'),
          child: IconButton(
            splashRadius: 22,
            tooltip: 'Notifications',
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () => _showNotifications(context, notifications),
          ),
        );
      },
    );
  }

  void _showNotifications(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> notifications,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.notifications_active, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Resident Alerts'),
              ],
            ),
            content: SizedBox(
              width: 420,
              child:
                  notifications.isEmpty
                      ? const Text('You have no notifications yet.')
                      : ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final notification = notifications[index];
                          final data = notification.data();
                          return ListTile(
                            leading: const Icon(
                              Icons.campaign,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              data['title'] ?? 'Barangay announcement',
                            ),
                            subtitle: Text(data['message'] ?? ''),
                            onTap: () {
                              notification.reference.update({'isRead': true});
                            },
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
