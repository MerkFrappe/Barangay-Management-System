import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/admin_documentRequest.dart';
import '../screens/residents_directory_screen.dart';
import '../screens/peace_and_order_screen.dart';
import '../screens/admin_reports_screen.dart';
import '../screens/emergency_broadcast_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/admin_emergency_reports_screen.dart';
import '../screens/admin_annoucements.dart';
import '../screens/community_polls_screen.dart';
import 'motion.dart';

class SidebarNav extends StatefulWidget {
  final int selectedIndex;
  final bool emergencySelected;
  final bool settingsSelected;

  const SidebarNav({
    super.key,
    this.selectedIndex = 0,
    this.emergencySelected = false,
    this.settingsSelected = false,
  });

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _SidebarNavState extends State<SidebarNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  static const _items = [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.group, 'Residents'),
    _NavItem(Icons.pending_actions, 'Requests'),
    _NavItem(Icons.gavel, 'Peace & Order'),
    _NavItem(Icons.assessment, 'Analytics'),
    _NavItem(Icons.warning_amber_rounded, 'Emergency Reports'),
    _NavItem(Icons.campaign, 'Announcements'),
    _NavItem(Icons.poll_outlined, 'Community Polls'),
  ];

  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const DashboardScreen();
        break;
      case 1:
        targetScreen = const ResidentsDirectoryScreen();
        break;
      case 2:
        targetScreen = const AdminDocumentRequestScreen();
        break;
      case 3:
        targetScreen = const PeaceAndOrderScreen();
        break;
      case 4:
        targetScreen = const AdminReportsScreen();
        break;
      case 5:
        targetScreen = const AdminEmergencyReportsScreen();
        break;
      case 6:
        targetScreen = const AnnouncementPage();
        break;
      case 7:
        targetScreen = const CommunityPollsScreen(isAdmin: true);
        break;
      default:
        targetScreen = const DashboardScreen();
    }
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(smoothPageRoute(targetScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(right: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 4,
            offset: Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo + title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Barangay Admin',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Official Portal',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Expanded(
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  top: _selectedIndex * 50,
                  left: 0,
                  right: 0,
                  height: 46,
                  child: Hero(
                    tag: 'admin-sidebar-highlight',
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _NavTile(
                      icon: item.icon,
                      label: item.label,
                      selected: index == _selectedIndex,
                      onTap: () => _onSelect(index),
                    );
                  },
                ),
              ],
            ),
          ),

          // Emergency broadcast button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(smoothPageRoute(const EmergencyBroadcastScreen()));
            },
            icon: const Icon(Icons.campaign, size: 20),
            label: const Text('Emergency Broadcast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.emergencySelected
                  ? AppColors.primary
                  : AppColors.tertiary,
              foregroundColor: AppColors.onTertiary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              textStyle: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 8),
          _NavTile(
            icon: Icons.settings,
            label: 'Settings',
            selected: widget.settingsSelected,
            onTap: () {
              Navigator.of(
                context,
              ).push(smoothPageRoute(const SettingsScreen()));
            },
          ),
          _NavTile(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacement(smoothPageRoute(const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
