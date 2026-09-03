import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class ResidentsDirectoryScreen extends StatefulWidget {
  const ResidentsDirectoryScreen({super.key});

  @override
  State<ResidentsDirectoryScreen> createState() => _ResidentsDirectoryScreenState();
}

class _ResidentsDirectoryScreenState extends State<ResidentsDirectoryScreen> {
  String _searchQuery = '';
  String _selectedZone = 'All Zones';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Complete Address / Zone', prefixIcon: Icon(Icons.home)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Number', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role / Designation'),
                  items: ['Resident', 'Barangay Official', 'Senior Citizen', 'Youth Leader']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
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
                        final newDoc = FirebaseFirestore.instance.collection('users').doc();
                        await newDoc.set({
                          'uid': newDoc.id,
                          'displayName': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim().isEmpty ? 'resident_${newDoc.id.substring(0, newDoc.id.length < 4 ? newDoc.id.length : 4)}@barangay.gov.ph' : emailCtrl.text.trim(),
                          'address': addressCtrl.text.trim().isEmpty ? 'Zone 1, Main St.' : addressCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim().isEmpty ? '+63 917 000 0000' : phoneCtrl.text.trim(),
                          'role': role,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Resident "${nameCtrl.text.trim()}" registered successfully!')),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Resident'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
          title: Text('Residents Directory',
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        ),
        drawer: const Drawer(child: SidebarNav(selectedIndex: 1)),
        body: body,
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resident & Household Registry',
                  style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(
                'Manage official resident profiles, addresses, voter status, and household records.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search resident by name, email, address...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedZone,
              items: ['All Zones', 'Zone 1', 'Zone 2', 'Zone 3', 'Purok 4', 'Purok 5']
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
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
              return Center(child: Text('Error loading residents: ${snapshot.error}'));
            }
            final docs = snapshot.data?.docs ?? [];
            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['displayName'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              final address = (data['address'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) || email.contains(_searchQuery) || address.contains(_searchQuery);
            }).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Resident Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filtered.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['displayName'] ?? 'Resident';
                  final email = data['email'] ?? 'N/A';
                  final address = data['address'] ?? 'Brgy. San Jose';
                  final role = data['role'] ?? 'Resident';

                  return DataRow(cells: [
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'R', style: TextStyle(color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Text(name, style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    )),
                    DataCell(Text(email)),
                    DataCell(Text(address)),
                    DataCell(Chip(label: Text(role), backgroundColor: AppColors.surfaceContainerHigh)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Editing profile for $name')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            onPressed: () async {
                              await doc.reference.delete();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Removed $name from database.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
