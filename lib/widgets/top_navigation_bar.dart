import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/resident_profile.dart';
import '../theme/app_colors.dart';
import 'notification_bell.dart';

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
    final compact = width < 600;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
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
                  hintText: compact
                      ? 'Search services or news'
                      : 'Search services, news, or guidelines...',
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

          SizedBox(width: compact ? 4 : 16),

          //---------------------------------------
          // Notification Button
          //---------------------------------------
          const NotificationBell(),

          SizedBox(width: compact ? 2 : 12),

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
              ? _fallbackUserInfo(desktop, compact)
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
                          radius: compact ? 18 : 22,
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

  Widget _fallbackUserInfo(bool desktop, bool compact) {
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
          radius: compact ? 18 : 22,
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
