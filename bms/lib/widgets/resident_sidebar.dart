import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/resident_dashboard_screen.dart';
import '../screens/resident_request_code.dart';
import '../screens/residence_announcements.dart' as announcements;
import '../screens/community_polls_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/health_center_screen.dart';

class ResidentSidebar extends StatelessWidget {
  final String selectedItem;

  const ResidentSidebar({super.key, this.selectedItem = 'My Dashboard'});

  void _showReportEmergencyModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String type = 'Fire Emergency';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Report Emergency to HQ',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your Name / Contact',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Exact Incident Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Category',
                    ),
                    items:
                        [
                              'Fire Emergency',
                              'Medical Emergency',
                              'Crime / Theft',
                              'Flood / Disaster',
                              'Accident',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => type = v!,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Immediate Details',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'EMERGENCY REPORT DISPATCHED TO BARANGAY HQ! Officials have been notified.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('SUBMIT EMERGENCY ALERT'),
              ),
            ],
          ),
    );
  }

  void _showHelpCenterModal(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Barangay Help Center'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequently Asked Questions:',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• How long does a Barangay Clearance take?\n  Typically 1-2 business days.',
                ),
                const SizedBox(height: 6),
                const Text(
                  '• What are the office hours?\n  Monday to Friday: 8:00 AM - 5:00 PM',
                ),
                const SizedBox(height: 12),
                Text(
                  'Official Contact:',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Hotline: +63 917 123 4567 | Email: help@barangay.gov.ph',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      color: AppColors.surfaceContainerLow,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO
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
<<<<<<< HEAD
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // NAVIGATION
              _NavItem(
                icon: Icons.dashboard_rounded,
                title: "My Dashboard",
                selected: true,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ResidentDashboardScreen()),
                  );
                },
              ),

              _NavItem(
                icon: Icons.assignment_outlined,
                title: "Document Request",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const DocumentRequest()),
                  );
                },
              ),

              _NavItem(
                icon: Icons.emergency_outlined,
                title: "Emergency Alerts",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const announcements.CivicHorizonApp(),
                    ),
                  );
                },
              ),

              _NavItem(
                icon: Icons.local_hospital_outlined,
                title: "Health Center & Services",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HealthCenterScreen()),
                  );
                },
              ),

              _NavItem(
                icon: Icons.poll_outlined,
                title: "Community Polls",
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CommunityPollsScreen()),
                  );
                },
              ),

              _NavItem(
                icon: Icons.help_outline,
                title: "Help Center",
                onTap: () => _showHelpCenterModal(context),
              ),

              const SizedBox(height: 24),

              // REPORT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showReportEmergencyModal(context),

                  icon: const Icon(Icons.campaign),

                  label: const Text("Report Emergency"),
=======
                  ],
>>>>>>> b54a044ce7e3c8d0c5826f7197d7ed4d6da67e03
                ),

                const SizedBox(height: 32),

                // NAVIGATION
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  title: "My Dashboard",
                  selected: selectedItem == 'My Dashboard',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ResidentDashboardScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.assignment_outlined,
                  title: "Document Request",
                  selected: selectedItem == 'Document Request',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const DocumentRequest(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.emergency_outlined,
                  title: "Emergency Alerts",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const announcements.CivicHorizonApp(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.local_hospital_outlined,
                  title: "Health Center & Services",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HealthCenterScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.poll_outlined,
                  title: "Community Polls",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const CommunityPollsScreen(),
                      ),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.help_outline,
                  title: "Help Center",
                  onTap: () => _showHelpCenterModal(context),
                ),

                _NavItem(
                  icon: Icons.admin_panel_settings_rounded,
                  title: "Switch to Admin",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // REPORT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _showReportEmergencyModal(context),

                    icon: const Icon(Icons.campaign),

                    label: const Text("Report Emergency"),
                  ),
                ),

                const SizedBox(height: 16),

                Divider(color: AppColors.outlineVariant),

                _NavItem(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                _NavItem(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
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
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
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

          onTap: onTap ?? () {},

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color:
                      selected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color:
                          selected
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
