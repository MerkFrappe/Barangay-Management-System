import 'dart:convert';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class ResidentsDirectoryScreen extends StatefulWidget {
  final String initialSearchQuery;

  const ResidentsDirectoryScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<ResidentsDirectoryScreen> createState() =>
      _ResidentsDirectoryScreenState();
}

class _ResidentsDirectoryScreenState extends State<ResidentsDirectoryScreen> {
  String _searchQuery = '';
  String _selectedZone = 'All Puroks';

  ImageProvider? _profilePhoto(Map<String, dynamic> data) {
    final encoded = data['profilePhotoBase64']?.toString();
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery.trim().toLowerCase();
  }

  void _showAddResidentDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String role = 'Resident';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Register New Resident'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Complete Address / Zone',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    labelText: 'Role / Designation',
                  ),
                  items:
                      [
                            'Resident',
                            'Barangay Official',
                            'Senior Citizen',
                            'Youth Leader',
                          ]
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (val) => setDialogState(() => role = val!),
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
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameCtrl.text.isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        final newDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc();
                        await newDoc.set({
                          'uid': newDoc.id,
                          'displayName': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim().isEmpty
                              ? 'resident_${newDoc.id.substring(0, newDoc.id.length < 4 ? newDoc.id.length : 4)}@barangay.gov.ph'
                              : emailCtrl.text.trim(),
                          'address': addressCtrl.text.trim().isEmpty
                              ? 'Zone 1, Main St.'
                              : addressCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim().isEmpty
                              ? '+63 917 000 0000'
                              : phoneCtrl.text.trim(),
                          'role': role,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Resident "${nameCtrl.text.trim()}" registered successfully!',
                            ),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Resident'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editResident(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(
      text: data['displayName']?.toString() ?? '',
    );
    final addressCtrl = TextEditingController(
      text: data['address']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text:
          data['phone']?.toString() ?? data['contactNumber']?.toString() ?? '',
    );
    final roleCtrl = TextEditingController(
      text: data['role']?.toString() ?? 'Resident',
    );
    final isEmailVerified = data['emailVerified'] == true;
    final isCurrentlyResident =
        roleCtrl.text.trim().toLowerCase() == 'resident';
    String? reportsTo = data['reportsTo']?.toString();
    String? photoBase64 = data['photoBase64']?.toString();
    final officials = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'Resident')
        .get();
    if (!mounted) return;
    final reportTargets = officials.docs
        .where((officer) => officer.id != doc.id)
        .toList();
    if (!reportTargets.any((officer) => officer.id == reportsTo)) {
      reportsTo = null;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Resident Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Complete Address / Purok',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  readOnly: isCurrentlyResident && !isEmailVerified,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Role / position',
                    helperText: 'Use Resident to remove officer status.',
                  ),
                ),
                if (isCurrentlyResident && !isEmailVerified)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'This resident must verify their email before they can be promoted.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                if (roleCtrl.text.trim().toLowerCase() != 'resident') ...[
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
                      ...reportTargets.map((officer) {
                        final officerData = officer.data();
                        final officerName =
                            (officerData['name'] ??
                                    officerData['displayName'] ??
                                    officerData['accountName'] ??
                                    'Unnamed officer')
                                .toString();
                        return DropdownMenuItem<String?>(
                          value: officer.id,
                          child: Text(officerName),
                        );
                      }),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => reportsTo = value),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await file_picker.FilePicker.pickFile(
                        type: file_picker.FileType.custom,
                        allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      );
                      if (file == null) return;
                      final bytes = await file.readAsBytes();
                      if (bytes.lengthInBytes > 650 * 1024) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
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
                          ? 'Upload officer photo (max 650 KB)'
                          : 'Replace officer photo',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final role = roleCtrl.text.trim().isEmpty
        ? 'Resident'
        : roleCtrl.text.trim();
    if (isCurrentlyResident &&
        !isEmailVerified &&
        role.toLowerCase() != 'resident') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only email-verified residents can be promoted.'),
          ),
        );
      }
      return;
    }
    final payload = <String, dynamic>{
      'displayName': nameCtrl.text.trim(),
      'accountName': nameCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'contactNumber': phoneCtrl.text.trim(),
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (role.toLowerCase() == 'resident') {
      payload['reportsTo'] = FieldValue.delete();
      payload['directoryManaged'] = FieldValue.delete();
    } else {
      payload['name'] = nameCtrl.text.trim();
      payload['reportsTo'] = reportsTo;
      payload['photoBase64'] = photoBase64 ?? '';
    }
    await doc.reference.update(payload);
    nameCtrl.dispose();
    addressCtrl.dispose();
    phoneCtrl.dispose();
    roleCtrl.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          role.toLowerCase() == 'resident'
              ? 'Resident profile updated.'
              : 'Resident promoted to $role.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSearchFilterCard(),
                const SizedBox(height: 24),
                _buildResidentsTable(),
              ],
            ),
          ),
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                const SidebarNav(selectedIndex: 1),
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
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            title: Text(
              'Residents Directory',
              style: AppTextStyles.headlineSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          drawer: const Drawer(child: SidebarNav(selectedIndex: 1)),
          body: body,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resident & Household Registry',
                style: AppTextStyles.headlineLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage official resident profiles, addresses, voter status, and household records.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showAddResidentDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Resident'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilterCard() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search resident by name, email, address...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedZone,
              items: [
                'All Puroks',
                '1-Pagaran',
                '1-B',
                '1-C',
                '1-D',
                '1-E',
                '2-Durian',
                '2-A',
                '3-Unit 1',
                '3-Unit 2',
                '3-Unit 3',
                '3-Unit 4',
                '3-Unit 5',
                '3-Unit 6',
                '3-Unit 7',
                '3-A',
                '3-B',
                '3-C',
                '3-D',
                '3-E',
                '3-F',
                '3-G',
                '3-H',
                '4',
                '4-A',
                '4-B',
                '4-C',
                '4-D',
                '4-E',
                '4-F',
                '4-G',
                '4-H',
                '5',
                '5A',
                '6',
                '6-A',
                '6-B',
                '7',
                'Purok 1',
                'Purok 10',
              ].map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (val) => setState(() => _selectedZone = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentsTable() {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading residents: ${snapshot.error}'),
              );
            }
            final docs = snapshot.data?.docs ?? [];
            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['displayName'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              final address = (data['address'] ?? '').toString().toLowerCase();
              final zoneMatches =
                  _selectedZone == 'All Puroks' ||
                  (data['purok'] ?? '').toString().toLowerCase() ==
                      _selectedZone.toLowerCase();
              return zoneMatches &&
                  (name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      address.contains(_searchQuery));
            }).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Resident Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Verified')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      (data['dashboardDisplayName'] ??
                              data['displayName'] ??
                              data['accountName'] ??
                              'Resident')
                          .toString();
                  final email = data['email'] ?? 'N/A';
                  final address = data['address'] ?? 'Brgy. San Jose';
                  final role = data['role'] ?? 'Resident';
                  final emailVerified = data['emailVerified'] == true;
                  final photo = _profilePhoto(data);

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              backgroundImage: photo,
                              child: photo == null
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'R',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              name,
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(email)),
                      DataCell(Text(address)),
                      DataCell(
                        Tooltip(
                          message: emailVerified
                              ? 'Email verified and eligible for promotion'
                              : 'Email verification is required before promotion',
                          child: Icon(
                            emailVerified
                                ? Icons.verified_rounded
                                : Icons.cancel_outlined,
                            color: emailVerified
                                ? Colors.green.shade700
                                : AppColors.outline,
                          ),
                        ),
                      ),
                      DataCell(
                        Chip(
                          label: Text(role),
                          backgroundColor: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () => _editResident(doc),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () async {
                                await doc.reference.delete();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Removed $name from database.',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
