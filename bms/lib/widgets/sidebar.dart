import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/admin_documentRequest.dart';
import '../screens/residents_directory_screen.dart';
import '../screens/peace_and_order_screen.dart';
import '../screens/admin_reports_screen.dart';
import '../screens/emergency_broadcast_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/health_center_screen.dart';
import '../screens/admin_annoucements.dart';

class SidebarNav extends StatefulWidget {
  final int selectedIndex;
  const SidebarNav({super.key, this.selectedIndex = 0});

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget Function() builder;
  final List<String> allowedRoles; // empty means all roles allowed

  const _NavItem({
    required this.icon,
    required this.label,
    required this.builder,
    this.allowedRoles = const [],
  });
}

class _SidebarNavState extends State<SidebarNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  static final List<_NavItem> _allNavItems = [
    _NavItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      builder: () => const DashboardScreen(),
    ),
    _NavItem(
      icon: Icons.group,
      label: 'Residents',
      builder: () => const ResidentsDirectoryScreen(),
      allowedRoles: ['chairman', 'admin', 'secretary'],
    ),
    _NavItem(
      icon: Icons.pending_actions,
      label: 'Requests',
      builder: () => const AdminDocumentRequestScreen(),
      allowedRoles: ['chairman', 'admin', 'secretary', 'treasurer', 'auditor'],
    ),
    _NavItem(
      icon: Icons.gavel,
      label: 'Peace & Order',
      builder: () => const PeaceAndOrderScreen(),
      allowedRoles: ['chairman', 'admin', 'councilor'],
    ),
    _NavItem(
      icon: Icons.assessment,
      label: 'Reports',
      builder: () => const AdminReportsScreen(),
      allowedRoles: ['chairman', 'admin', 'secretary', 'treasurer', 'auditor'],
    ),
    _NavItem(
      icon: Icons.local_hospital,
      label: 'Health Center',
      builder: () => const HealthCenterScreen(isAdmin: true),
      allowedRoles: ['chairman', 'admin', 'councilor'],
    ),
    _NavItem(
      icon: Icons.campaign,
      label: 'Announcements',
      builder: () => const AnnouncementPage(),
      allowedRoles: ['chairman', 'admin'], // Excluded for Councilor & Secretary
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    final userStream = uid != null
        ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
        : null;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final role = (data?['role'] ?? 'Chairman').toString();
        final name = (data?['fullName'] ?? data?['name'] ?? currentUser?.displayName ?? 'Barangay Official').toString();
        final email = currentUser?.email ?? 'official@barangay.gov.ph';
        final normRole = role.toLowerCase().trim();

        // Filter nav items by user role
        final visibleItems = _allNavItems.where((item) {
          if (item.allowedRoles.isEmpty) return true;
          return item.allowedRoles.contains(normRole);
        }).toList();

        // Ensure selected index remains in bounds
        final safeIndex = _selectedIndex >= visibleItems.length ? 0 : _selectedIndex;

        // Emergency Broadcast button only for Chairman / Admin
        final canBroadcast = normRole == 'chairman' || normRole == 'admin';

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
              // Logo + Header with dynamic role
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barangay Hub',
                            style: AppTextStyles.headlineSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Portal • $role',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Nav Items
              Expanded(
                child: ListView.separated(
                  itemCount: visibleItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final item = visibleItems[index];
                    final selected = index == safeIndex;
                    return _NavTile(
                      icon: item.icon,
                      label: item.label,
                      selected: selected,
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => item.builder()),
                        );
                      },
                    );
                  },
                ),
              ),

              // Emergency Broadcast Button (Hidden for Councilor & Secretary)
              if (canBroadcast) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmergencyBroadcastScreen()),
                    );
                  },
                  icon: const Icon(Icons.campaign, size: 20),
                  label: const Text('Emergency Broadcast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
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
                const SizedBox(height: 12),
              ],

              // User Profile Footer
              Tooltip(
                message: email,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'O',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$role • $email',
                              style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: 8),
              _NavTile(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              _NavTile(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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

