import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class PeaceAndOrderScreen extends StatefulWidget {
  const PeaceAndOrderScreen({super.key});

  @override
  State<PeaceAndOrderScreen> createState() => _PeaceAndOrderScreenState();
}

class _PeaceAndOrderScreenState extends State<PeaceAndOrderScreen> {
  String _selectedStatus = 'All Statuses';

  void _showFileBlotterDialog() {
    final complainantCtrl = TextEditingController();
    final respondentCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String category = 'Noise Disturbance';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.gavel, color: AppColors.tertiary),
              const SizedBox(width: 12),
              const Text('File Incident Blotter'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: complainantCtrl,
                  decoration: const InputDecoration(labelText: 'Complainant Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: respondentCtrl,
                  decoration: const InputDecoration(labelText: 'Respondent Name / Party', prefixIcon: Icon(Icons.person_off)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Incident Category'),
                  items: ['Noise Disturbance', 'Boundary Dispute', 'Physical Altercation', 'Property Damage', 'Theft', 'Other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => category = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Incident Summary / Details', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.tertiary, foregroundColor: AppColors.onTertiary),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (complainantCtrl.text.isEmpty) return;
                      setDialogState(() => isSaving = true);
                      try {
                        final newDoc = FirebaseFirestore.instance.collection('incidents').doc();
                        await newDoc.set({
                          'id': newDoc.id,
                          'complainant': complainantCtrl.text.trim(),
                          'respondent': respondentCtrl.text.trim().isEmpty ? 'Unknown Party' : respondentCtrl.text.trim(),
                          'category': category,
                          'details': detailsCtrl.text.trim(),
                          'status': 'Open',
                          'dateLogged': DateTime.now().toString().substring(0, 10),
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incident Blotter recorded successfully!')),
                        );
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                      }
                    },
              child: isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('File Report'),
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
              _buildStatOverview(isWide),
              const SizedBox(height: 24),
              _buildBlotterTableCard(),
            ],
          ),
        ),
      );

      if (isWide) {
        return Scaffold(
          body: Row(
            children: [
              const SidebarNav(selectedIndex: 3),
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
          title: Text('Peace & Order Log', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        ),
        drawer: const Drawer(child: SidebarNav(selectedIndex: 3)),
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
              Text('Peace & Order Blotter', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(
                'Log, track, and resolve community complaints, barangay conciliations, and security incidents.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showFileBlotterDialog,
          icon: const Icon(Icons.add_moderator),
          label: const Text('File Blotter Incident'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            foregroundColor: AppColors.onTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatOverview(bool isWide) {
    final stats = [
      _StatBox('Active Blotters', '5', AppColors.errorContainer, AppColors.error),
      _StatBox('Under Mediation', '3', AppColors.secondaryContainer, AppColors.secondary),
      _StatBox('Settled This Month', '14', AppColors.primaryContainer, AppColors.onPrimary),
    ];
    if (isWide) {
      return Row(children: stats.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: s))).toList());
    }
    return Column(children: stats.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12), child: s)).toList());
  }

  Widget _buildBlotterTableCard() {
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
          stream: FirebaseFirestore.instance.collection('incidents').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Incident Blotter Registry (${docs.length})', style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: ['All Statuses', 'Open', 'Under Investigation', 'Resolved']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Blotter No.')),
                      DataColumn(label: Text('Complainant')),
                      DataColumn(label: Text('Respondent')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Date Logged')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'Open';
                      return DataRow(cells: [
                        DataCell(Text('BLT-${doc.id.substring(0, doc.id.length < 4 ? doc.id.length : 4).toUpperCase()}')),
                        DataCell(Text(data['complainant'] ?? 'N/A')),
                        DataCell(Text(data['respondent'] ?? 'N/A')),
                        DataCell(Text(data['category'] ?? 'General')),
                        DataCell(
                          Chip(
                            label: Text(status),
                            backgroundColor: status == 'Resolved' ? AppColors.primaryContainer : AppColors.errorContainer,
                          ),
                        ),
                        DataCell(Text(data['dateLogged'] ?? '2026-08-12')),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (newStatus) async {
                              await doc.reference.update({'status': newStatus});
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Open', child: Text('Mark as Open')),
                              const PopupMenuItem(value: 'Under Investigation', child: Text('Mark Under Investigation')),
                              const PopupMenuItem(value: 'Resolved', child: Text('Mark as Resolved')),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String val;
  final Color bg;
  final Color textCol;
  const _StatBox(this.label, this.val, this.bg, this.textCol);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: AppTextStyles.headlineLg.copyWith(color: textCol, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelMd.copyWith(color: textCol.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
