import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/resident_dashboard_screen.dart';

class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSwitchPortal;
  const TopHeader({super.key, this.onSwitchPortal});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          // Search bar
          Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search residents, records, or services...',
                      hintStyle: AppTextStyles.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: AppTextStyles.bodySm,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Portal Switch Button
          ElevatedButton.icon(
            onPressed: onSwitchPortal ??
                () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const ResidentDashboardScreen()),
                  );
                },
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Switch to Resident View'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Notifications
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined,
                  color: AppColors.onSurfaceVariant),
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(color: AppColors.outlineVariant)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chairman Juan Dela Cruz',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.primary)),
                    Text('BARANGAY PRESIDING OFFICER',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
