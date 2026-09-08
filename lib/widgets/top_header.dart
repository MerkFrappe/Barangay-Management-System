import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'notification_bell.dart';

class TopHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSwitchPortal;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  const TopHeader({
    super.key,
    this.onSwitchPortal,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1050;

        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
          ),
          child: Row(
            children: [
              // Search bar
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Container(
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
                            onChanged: onSearchChanged,
                            onSubmitted: onSearchSubmitted,
                            decoration: InputDecoration(
                              hintText:
                                  'Search residents, records, or services...',
                              hintStyle: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: AppTextStyles.bodySm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!compact) const Spacer() else const SizedBox(width: 8),

              // Notifications
              const NotificationBell(isAdmin: true),
              if (!compact) const SizedBox(width: 8),
              if (!compact)
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Barangay HQ Admin Guide'),
                        content: const Text(
                          'For system support or inquiries, contact IT Admin at admin@barangay.gov.ph or extension 101.',
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
              if (!compact) const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    if (!compact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Chairman Juan Dela Cruz',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'BARANGAY PRESIDING OFFICER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    if (!compact) const SizedBox(width: 12),
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
      },
    );
  }
}
