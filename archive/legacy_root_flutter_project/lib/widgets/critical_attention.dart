import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CriticalAttention extends StatelessWidget {
  const CriticalAttention({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              Text('Critical Attention',
                  style: AppTextStyles.headlineSm
                      .copyWith(color: AppColors.onSurface)),
            ],
          ),
          const SizedBox(height: 20),
          _CriticalItem(
            icon: Icons.delete_forever,
            iconBg: AppColors.error,
            iconColor: AppColors.onError,
            bg: AppColors.errorContainer.withValues(alpha: 0.2),
            border: AppColors.errorContainer,
            title: 'Urgent Citizen Complaint',
            titleColor: AppColors.error,
            body: 'Illegal waste dumping reported at Zone 4 near Creek area.',
            actionText: 'Dispatch Patrol',
            actionColor: AppColors.error,
          ),
          const SizedBox(height: 16),
          _CriticalItem(
            icon: Icons.description,
            iconBg: AppColors.secondary,
            iconColor: AppColors.onSecondary,
            bg: AppColors.secondaryContainer.withValues(alpha: 0.2),
            border: AppColors.secondaryContainer,
            title: 'Pending Blotter #2023-442',
            titleColor: AppColors.onSecondaryContainer,
            body:
                'Mediation scheduled for 2:00 PM today between Party A and B.',
            actionText: 'View Case File',
            actionColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _CriticalItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color bg;
  final Color border;
  final String title;
  final Color titleColor;
  final String body;
  final String actionText;
  final Color actionColor;

  const _CriticalItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.bg,
    required this.border,
    required this.title,
    required this.titleColor,
    required this.body,
    required this.actionText,
    required this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: titleColor)),
                const SizedBox(height: 4),
                Text(body,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(actionText,
                          style: AppTextStyles.labelSm.copyWith(
                              color: actionColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline)),
                      Icon(Icons.chevron_right, size: 16, color: actionColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
