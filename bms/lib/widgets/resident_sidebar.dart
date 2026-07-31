import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ResidentSidebar extends StatelessWidget {
  const ResidentSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //---------------------------------
              // LOGO
              //---------------------------------
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Barangay Digital",
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Resident Portal",
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              //---------------------------------
              // NAVIGATION
              //---------------------------------
              _NavItem(
                icon: Icons.dashboard_rounded,
                title: "My Dashboard",
                selected: true,
              ),

              _NavItem(
                icon: Icons.assignment_outlined,
                title: "Permit Tracking",
              ),

              _NavItem(
                icon: Icons.emergency_outlined,
                title: "Emergency Alerts",
              ),

              _NavItem(icon: Icons.poll_outlined, title: "Community Polls"),

              _NavItem(icon: Icons.help_outline, title: "Help Center"),

              const Spacer(),

              //---------------------------------
              // REPORT BUTTON
              //---------------------------------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tertiaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},

                  icon: const Icon(Icons.campaign),

                  label: const Text("Report Emergency"),
                ),
              ),

              const SizedBox(height: 20),

              Divider(color: AppColors.outlineVariant),

              _NavItem(icon: Icons.settings_outlined, title: "Settings"),

              _NavItem(icon: Icons.logout, title: "Logout"),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.title,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: () {},

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: selected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
