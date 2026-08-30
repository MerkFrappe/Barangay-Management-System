import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverviewCards extends StatelessWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Stream of users count where role is Resident
    final residentsStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Resident')
        .snapshots()
        .map((snap) => snap.docs.length);

    // 2. Stream of document requests
    final requestsStream = FirebaseFirestore.instance
        .collection('document_requests')
        .snapshots();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1000 ? 4 : (width > 640 ? 2 : 1);

        return StreamBuilder<int>(
          stream: residentsStream,
          builder: (context, residentSnapshot) {
            final totalResidents = residentSnapshot.data ?? 0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: requestsStream,
              builder: (context, requestSnapshot) {
                final requests = requestSnapshot.data?.docs ?? [];

                final pendingCount = requests
                    .where((doc) => doc.data()['status'] == 'pending')
                    .length;
                final issuedClearancesCount = requests
                    .where(
                      (doc) =>
                          doc.data()['status'] == 'approved' &&
                          doc.data()['documentType'] == 'Barangay Clearance',
                    )
                    .length;

                final activePeaceAndOrder =
                    2; // Keep static for visual alignment

                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.7,
                  children: [
                    _StatCard(
                      icon: Icons.group,
                      iconBg: AppColors.surfaceContainer,
                      iconColor: AppColors.primary,
                      badgeText: '+2.4%',
                      badgeIcon: Icons.trending_up,
                      badgeColor: AppColors.successGreen,
                      badgeBg: AppColors.successGreenBg,
                      label: 'Total Residents',
                      value: totalResidents.toString(),
                      valueColor: AppColors.primary,
                    ),
                    _StatCard(
                      icon: Icons.hourglass_empty,
                      iconBg: AppColors.secondaryContainer,
                      iconColor: AppColors.onSecondaryContainer,
                      badgeText: 'Action Required',
                      badgeColor: AppColors.secondary,
                      badgeBg: AppColors.secondaryFixed,
                      label: 'Pending Requests',
                      value: pendingCount.toString(),
                      valueColor: AppColors.secondary,
                      leftBorderColor: AppColors.secondary,
                    ),
                    _StatCard(
                      icon: Icons.gavel,
                      iconBg: AppColors.errorContainer,
                      iconColor: AppColors.error,
                      badgeText: 'Priority',
                      badgeColor: AppColors.error,
                      badgeBg: AppColors.errorContainer,
                      label: 'Active Peace & Order',
                      value: activePeaceAndOrder.toString(),
                      valueColor: AppColors.error,
                      leftBorderColor: AppColors.error,
                    ),
                    _StatCard(
                      icon: Icons.verified,
                      iconBg: AppColors.surfaceContainer,
                      iconColor: AppColors.primary,
                      badgeText: 'Monthly',
                      badgeColor: AppColors.onSurfaceVariant,
                      badgeBg: AppColors.surfaceVariant,
                      label: 'Issued Clearances',
                      value: issuedClearancesCount.toString(),
                      valueColor: AppColors.primary,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String badgeText;
  final IconData? badgeIcon;
  final Color badgeColor;
  final Color badgeBg;
  final String label;
  final String value;
  final Color valueColor;
  final Color? leftBorderColor;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeText,
    this.badgeIcon,
    required this.badgeColor,
    required this.badgeBg,
    required this.label,
    required this.value,
    required this.valueColor,
    this.leftBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (leftBorderColor != null)
            Positioned(
              left: -20,
              top: -20,
              bottom: -20,
              child: Container(width: 4, color: leftBorderColor),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        if (badgeIcon != null) ...[
                          Icon(badgeIcon, size: 14, color: badgeColor),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          badgeText,
                          style: AppTextStyles.labelSm.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.headlineMd.copyWith(color: valueColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
