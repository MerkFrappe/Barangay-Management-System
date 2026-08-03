import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/resident_dashboard_screen.dart';

class SidebarNav extends StatefulWidget {
  const SidebarNav({super.key});

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _SidebarNavState extends State<SidebarNav> {
  int _selectedIndex = 0;

  static const _items = [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.group, 'Residents'),
    _NavItem(Icons.pending_actions, 'Requests'),
    _NavItem(Icons.security, 'Peace & Order'),
    _NavItem(Icons.assessment, 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: AppColors.outlineVariant),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 4, offset: Offset(1, 0)),
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
                    Text('Barangay Admin',
                        style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    Text('Official Portal',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _items[index];
                final selected = index == _selectedIndex;
                return _NavTile(
                  icon: item.icon,
                  label: item.label,
                  selected: selected,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
          // Switch to Resident View Action Tile
          _NavTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch to Resident',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const ResidentDashboardScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          // Emergency broadcast button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.campaign, size: 20),
            label: const Text('Emergency Broadcast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.onTertiary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              textStyle:
                  AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 8),
          _NavTile(icon: Icons.settings, label: 'Settings', onTap: () {}),
          _NavTile(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
      color: selected ? AppColors.primaryFixed : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant),
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
