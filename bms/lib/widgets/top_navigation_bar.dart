import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

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

          const SizedBox(width: 20),

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
            onPressed: () {},
          ),

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
