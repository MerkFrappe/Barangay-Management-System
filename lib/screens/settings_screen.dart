import 'dart:convert';

import 'package:file_picker/file_picker.dart' as file_picker;
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

  Future<void> _showOfficerEditor({
    DocumentSnapshot<Map<String, dynamic>>? existing,
  }) async {
    final data = existing?.data() ?? const <String, dynamic>{};
    final nameController = TextEditingController(
      text: (data['name'] ?? data['accountName'] ?? '').toString(),
    );
    final roleController = TextEditingController(
      text: (data['role'] ?? 'Kagawad').toString(),
    );
    String? reportsTo = data['reportsTo']?.toString();
    String? photoBase64 = data['photoBase64']?.toString();
    final officials = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'Resident')
        .get();
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existing == null ? 'Add barangay officer' : 'Edit barangay officer',
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role / position',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: reportsTo,
                    decoration: const InputDecoration(
                      labelText: 'Reports to (hierarchy)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Top-level officer'),
                      ),
                      ...officials.docs
                          .where((doc) => doc.id != existing?.id)
                          .map((doc) {
                            final officer = doc.data();
                            final name =
                                (officer['name'] ??
                                        officer['accountName'] ??
                                        'Unnamed officer')
                                    .toString();
                            return DropdownMenuItem<String?>(
                              value: doc.id,
                              child: Text(name),
                            );
                          }),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => reportsTo = value),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await file_picker.FilePicker.pickFile(
                        type: file_picker.FileType.custom,
                        allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      );
                      if (file == null) {
                        return;
                      }
                      final bytes = await file.readAsBytes();
                      if (bytes.lengthInBytes > 650 * 1024) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile photo must be 650 KB or smaller.',
                              ),
                            ),
                          );
                        }
                        return;
                      }
                      setDialogState(() => photoBase64 = base64Encode(bytes));
                    },
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(
                      photoBase64 == null || photoBase64!.isEmpty
                          ? 'Upload profile photo (max 650 KB)'
                          : 'Replace profile photo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    roleController.text.trim().isEmpty) {
                  return;
                }
                final payload = <String, dynamic>{
                  'name': nameController.text.trim(),
                  'accountName': nameController.text.trim(),
                  'role': roleController.text.trim(),
                  'reportsTo': reportsTo,
                  'photoBase64': photoBase64 ?? '',
                  'directoryManaged': true,
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (existing == null) {
                  payload['createdAt'] = FieldValue.serverTimestamp();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .add(payload);
                } else {
                  await existing.reference.set(
                    payload,
                    SetOptions(merge: true),
                  );
                }
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save officer'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    roleController.dispose();
  }

  Widget _officersManager() => Card(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Barangay Officers',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showOfficerEditor(),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add officer'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Set reporting relationships to build the resident-facing hierarchy. Photos are stored in Firestore and limited to 650 KB.',
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isNotEqualTo: 'Resident')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text('No officers yet.');
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final name =
                      (data['name'] ?? data['accountName'] ?? 'Unnamed officer')
                          .toString();
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name),
                    subtitle: Text(data['role']?.toString() ?? 'Official'),
                    trailing: Wrap(
                      spacing: 2,
                      children: [
                        IconButton(
                          tooltip: 'Edit officer',
                          onPressed: () => _showOfficerEditor(existing: doc),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: data['directoryManaged'] == true
                              ? 'Remove officer'
                              : 'Account-managed officer cannot be removed here',
                          onPressed: data['directoryManaged'] == true
                              ? () => doc.reference.delete()
                              : null,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );

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
                _officersManager(),
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
