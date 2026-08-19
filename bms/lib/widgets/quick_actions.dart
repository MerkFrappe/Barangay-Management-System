import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/admin_annoucements.dart';
import '../screens/admin_documentRequest.dart';
import '../screens/emergency_broadcast_screen.dart';

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
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementPage()));
            },
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
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentRequestScreen()));
            },
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
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyBroadcastScreen()));
            },
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
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
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
        onTap: onTap,
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
