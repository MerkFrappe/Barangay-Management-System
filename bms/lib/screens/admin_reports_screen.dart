import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = 'This Month';
  String _selectedCategory = 'All Categories';
  String _selectedFormat = 'PDF';
  bool _isExporting = false;

  void _exportReport() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isExporting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            const Text('Report Exported'),
          ],
        ),
        content: Text(
          'The $_selectedCategory report for $_selectedPeriod has been generated successfully in $_selectedFormat format.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.download_done),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
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
              _buildKpiGrid(isWide),
              const SizedBox(height: 24),
              _buildFilterSection(isWide),
              const SizedBox(height: 24),
              _buildReportTableCard(),
            ],
          ),
        ),
      );

      if (isWide) {
        return Scaffold(
          body: Row(
            children: [
              const SidebarNav(selectedIndex: 4),
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
          title: Text('Barangay Reports',
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        ),
        drawer: const Drawer(child: SidebarNav(selectedIndex: 4)),
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
              Text('Reports & Analytics Hub',
                  style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text(
                'Generate official barangay documentation summaries, financial logs, and incident reports.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportReport,
          icon: _isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(_isExporting ? 'Generating...' : 'Export Official Summary'),
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

  Widget _buildKpiGrid(bool isWide) {
    final kpis = [
      _KpiCard('Total Certificates Issued', '142', Icons.card_membership, AppColors.primaryContainer, AppColors.onPrimary),
      _KpiCard('Monthly Revenue', '₱ 28,400', Icons.payments, AppColors.tertiaryContainer, AppColors.onTertiary),
      _KpiCard('Incidents Resolved', '18 / 20', Icons.gavel, AppColors.secondaryContainer, AppColors.secondary),
      _KpiCard('Active Population', '4,892', Icons.people_alt, AppColors.surfaceContainerHighest, AppColors.onSurface),
    ];

    if (isWide) {
      return Row(
        children: kpis.map((kpi) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: kpi))).toList(),
      );
    }
    return Column(
      children: kpis.map((kpi) => Padding(padding: const EdgeInsets.only(bottom: 12), child: kpi)).toList(),
    );
  }

  Widget _buildFilterSection(bool isWide) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.filter_alt, color: AppColors.primary),
            Text('Report Filters:', style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedPeriod,
              items: ['Today', 'This Week', 'This Month', 'This Quarter', 'This Year']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPeriod = val!),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ['All Categories', 'Clearances & Permits', 'Peace & Order', 'Financial Summary', 'Resident Demographics']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            DropdownButton<String>(
              value: _selectedFormat,
              items: ['PDF', 'CSV', 'Excel']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedFormat = val!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTableCard() {
    return Card(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Generated Activity Logs',
                    style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.bold)),
                Chip(
                  label: const Text('Live Firestore Sync'),
                  avatar: const Icon(Icons.sync, size: 16),
                  backgroundColor: AppColors.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('document_requests').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Report ID')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Requestor')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Date Logged')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text(doc.id.substring(0, doc.id.length < 6 ? doc.id.length : 6).toUpperCase())),
                        DataCell(Text(data['documentType'] ?? 'Document')),
                        DataCell(Text(data['residentName'] ?? 'Resident')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data['status'] ?? 'Completed',
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                        DataCell(Text(data['dateSubmitted'] ?? '2026-08-12')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.download, size: 20),
                            onPressed: _exportReport,
                            tooltip: 'Download Copy',
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _KpiCard(this.title, this.value, this.icon, this.bgColor, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.headlineLg.copyWith(fontWeight: FontWeight.bold, color: iconColor)),
            const SizedBox(height: 4),
            Text(title, style: AppTextStyles.bodySm.copyWith(color: iconColor.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
