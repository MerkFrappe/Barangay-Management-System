import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _smsAlerts = true;
  bool _autoApproveClearance = false;

  final _brgyNameCtrl = TextEditingController(text: 'Barangay San Jose');
  final _chairmanCtrl = TextEditingController(text: 'Hon. Barangay Chairman');
  final _hotlineCtrl = TextEditingController(text: '+63 917 123 4567');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('main')
        .get();
    if (!mounted || !snapshot.exists) return;
    final data = snapshot.data() ?? {};
    setState(() {
      _brgyNameCtrl.text =
          data['barangayName']?.toString() ?? _brgyNameCtrl.text;
      _chairmanCtrl.text =
          data['chairmanName']?.toString() ?? _chairmanCtrl.text;
      _hotlineCtrl.text =
          data['emergencyHotline']?.toString() ?? _hotlineCtrl.text;
      _emailNotifications =
          data['emailNotifications'] as bool? ?? _emailNotifications;
      _smsAlerts = data['smsAlerts'] as bool? ?? _smsAlerts;
      _autoApproveClearance =
          data['autoApproveClearance'] as bool? ?? _autoApproveClearance;
    });
  }

  Future<void> _saveSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('system_settings')
          .doc('main')
          .set({
            'barangayName': _brgyNameCtrl.text.trim(),
            'chairmanName': _chairmanCtrl.text.trim(),
            'emergencyHotline': _hotlineCtrl.text.trim(),
            'emailNotifications': _emailNotifications,
            'smsAlerts': _smsAlerts,
            'autoApproveClearance': _autoApproveClearance,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barangay System Settings saved successfully!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save settings: $error')),
      );
    }
  }

  @override
  void dispose() {
    _brgyNameCtrl.dispose();
    _chairmanCtrl.dispose();
    _hotlineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'System Settings & Configuration',
                  style: AppTextStyles.headlineLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage official barangay profile info, notification preferences, and system automation.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official Barangay Profile',
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _brgyNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Barangay Name',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _chairmanCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Barangay Captain / Chairman',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _hotlineCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Official Emergency Hotline',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System & Notification Preferences',
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text(
                            'Email Notifications for Document Requests',
                          ),
                          value: _emailNotifications,
                          onChanged: (val) =>
                              setState(() => _emailNotifications = val),
                        ),
                        SwitchListTile(
                          title: const Text('SMS Emergency Alert Gateway'),
                          value: _smsAlerts,
                          onChanged: (val) => setState(() => _smsAlerts = val),
                        ),
                        SwitchListTile(
                          title: const Text(
                            'Auto-Verification for First-Time Resident Clearances',
                          ),
                          value: _autoApproveClearance,
                          onChanged: (val) =>
                              setState(() => _autoApproveClearance = val),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save System Settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                const SidebarNav(selectedIndex: -1, settingsSelected: true),
                Expanded(
                  child: Column(
                    children: [
                      const TopHeader(),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Settings')),
          drawer: const Drawer(
            child: SidebarNav(selectedIndex: -1, settingsSelected: true),
          ),
          body: body,
        );
      },
    );
  }
}
