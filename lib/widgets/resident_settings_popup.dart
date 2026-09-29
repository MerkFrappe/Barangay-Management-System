import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/profile_completion_screen.dart';

/// Small popup used from the resident sidebar's "Settings" item.
///
/// Replaces the previous behavior of pushing the admin [SettingsScreen].
/// Only exposes what a resident actually needs: editing their own profile
/// details, and logging out (moved here from the sidebar's standalone
/// Logout item).
Future<void> showResidentSettingsPopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  'Account',
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Edit profile',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileCompletionScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.outlineVariant),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Log out',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    ),
  );
}
