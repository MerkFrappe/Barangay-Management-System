import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';

class TopNavigationBar extends StatefulWidget {
  final VoidCallback? onSwitchPortal;
  const TopNavigationBar({super.key, this.onSwitchPortal});

  @override
  State<TopNavigationBar> createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _profileStream = uid == null
        ? null
        : FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

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
              builder: (context) => IconButton(
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
          IconButton(
            splashRadius: 22,
            tooltip: "Notifications",
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Text('Resident Alerts'),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Clearance Ready for Pickup'),
                        subtitle: Text(
                          'Barangay Clearance #REQ-102 has been approved.',
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.campaign, color: Colors.amber),
                        title: Text('Barangay Assembly Notice'),
                        subtitle: Text('Meeting on Aug 15 at 9:00 AM.'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          //---------------------------------------
          // Divider
          //---------------------------------------
          if (desktop)
            Container(width: 1, height: 36, color: AppColors.outlineVariant),

          if (desktop) const SizedBox(width: 18),

          //---------------------------------------
          // User Info + Avatar (live from the resident's own profile)
          //---------------------------------------
          _profileStream == null
              ? _fallbackUserInfo(desktop)
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _profileStream,
                  builder: (context, snapshot) {
                    final profile = ResidentProfile.fromMap(
                      snapshot.data?.data(),
                    );
                    final name = profile.fullName.isNotEmpty
                        ? profile.fullName
                        : (FirebaseAuth.instance.currentUser?.email ??
                              'Resident');
                    final initials = profile.initials.isNotEmpty
                        ? profile.initials
                        : 'R';

                    return Row(
                      children: [
                        if (desktop)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Resident",
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        if (desktop) const SizedBox(width: 14),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            initials,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _fallbackUserInfo(bool desktop) {
    return Row(
      children: [
        if (desktop)
          Text(
            "Resident",
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (desktop) const SizedBox(width: 14),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            "R",
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
