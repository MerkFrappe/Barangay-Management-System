import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.post_add,
            label: 'Post Announcement',
            bg: AppColors.primaryContainer,
            fg: AppColors.onPrimary,
            iconBg: AppColors.onPrimaryFixedVariant,
            iconColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.print,
            label: 'Issue Clearance',
            bg: AppColors.surfaceContainerLowest,
            fg: AppColors.primary,
            iconBg: AppColors.primaryFixed,
            iconColor: AppColors.primary,
            borderColor: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionButton(
            icon: Icons.emergency_share,
            label: 'Broadcast Emergency',
            bg: AppColors.surfaceContainerLowest,
            fg: AppColors.error,
            iconBg: AppColors.errorContainer,
            iconColor: AppColors.error,
            borderColor: AppColors.errorContainer,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final Color iconBg;
  final Color iconColor;
  final Color? borderColor;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.iconBg,
    required this.iconColor,
    this.borderColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      elevation: filled ? 3 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMd.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
