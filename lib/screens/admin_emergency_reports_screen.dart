import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

class AdminEmergencyReportsScreen extends StatefulWidget {
  const AdminEmergencyReportsScreen({super.key});

  @override
  State<AdminEmergencyReportsScreen> createState() =>
      _AdminEmergencyReportsScreenState();
}

class _AdminEmergencyReportsScreenState
    extends State<AdminEmergencyReportsScreen> {
  String? _selectedReportId;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final body = _selectedReportId == null
        ? _EmergencyReportsList(
            onSelect: (id) => setState(() => _selectedReportId = id),
          )
        : _EmergencyReportDetail(
            reportId: _selectedReportId!,
            onBack: () => setState(() => _selectedReportId = null),
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: wide ? null : const Drawer(child: SidebarNav(selectedIndex: 5)),
      appBar: wide
          ? null
          : AppBar(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.primary,
              title: const Text('Emergency Reports'),
            ),
      body: Row(
        children: [
          if (wide) const SidebarNav(selectedIndex: 5),
          Expanded(
            child: Column(
              children: [
                if (wide) const TopHeader(),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyReportsList extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _EmergencyReportsList({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('emergency_reports')
          .snapshots(),
      builder: (context, snapshot) {
        final reports = snapshot.data?.docs.toList() ?? [];
        reports.sort(
          (a, b) => _createdAt(b.data()).compareTo(_createdAt(a.data())),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency Reports',
                            style: AppTextStyles.headlineLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Review emergencies submitted by residents.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (snapshot.hasError)
                  const _EmptyEmergencyState(
                    message: 'Emergency reports could not be loaded right now.',
                  )
                else if (reports.isEmpty)
                  const _EmptyEmergencyState(
                    message: 'No emergency reports have been submitted yet.',
                  )
                else
                  ...reports.map(
                    (report) => _EmergencyReportListCard(
                      report: report,
                      onTap: () => onSelect(report.id),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmergencyReportListCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> report;
  final VoidCallback onTap;
  const _EmergencyReportListCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final data = report.data();
    final status = (data['status'] ?? 'submitted').toString();
    final color = _statusColor(status);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.errorContainer,
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
        ),
        title: Text(
          (data['type'] ?? 'Emergency').toString(),
          style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${data['residentName'] ?? 'Resident'} • ${_formattedDate(_createdAt(data))}',
          ),
        ),
        trailing: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusChip(status: status, color: color),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmergencyReportDetail extends StatelessWidget {
  final String reportId;
  final VoidCallback onBack;
  const _EmergencyReportDetail({required this.reportId, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('emergency_reports')
          .doc(reportId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          return const _EmptyEmergencyState(
            message: 'This emergency report is no longer available.',
          );
        }
        final data = snapshot.data!.data()!;
        final status = (data['status'] ?? 'submitted').toString();
        final latitude = (data['latitude'] as num?)?.toDouble();
        final longitude = (data['longitude'] as num?)?.toDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to reports'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Emergency Report',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Submitted by a resident',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final detail = _ReportInformation(
                        data: data,
                        reportId: reportId,
                        latitude: latitude,
                        longitude: longitude,
                      );
                      final controls = _ReportControls(
                        reportId: reportId,
                        status: status,
                        createdAt: _createdAt(data),
                      );
                      if (constraints.maxWidth >= 850) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: detail),
                            const SizedBox(width: 20),
                            Expanded(flex: 4, child: controls),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          detail,
                          const SizedBox(height: 20),
                          controls,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReportInformation extends StatelessWidget {
  final Map<String, dynamic> data;
  final String reportId;
  final double? latitude;
  final double? longitude;
  const _ReportInformation({
    required this.data,
    required this.reportId,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final hasMap = latitude != null && longitude != null;
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryFixed,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data['residentName'] ?? 'Resident').toString(),
                        style: AppTextStyles.titleLg,
                      ),
                      Text(
                        (data['contactNumber'] ?? 'No contact number provided')
                            .toString(),
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Emergency Category',
              value: (data['type'] ?? 'Emergency').toString(),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Exact Incident Location',
              value: (data['location'] ?? 'Location not provided').toString(),
            ),
            if (hasMap) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 240,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude!, longitude!),
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.barangay.bms',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude!, longitude!),
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.location_pin,
                              size: 48,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text('Immediate Details', style: AppTextStyles.titleMd),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (data['details'] ?? 'No additional details were provided.')
                    .toString(),
                style: AppTextStyles.bodyMd,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Report ID: $reportId',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportControls extends StatelessWidget {
  final String reportId;
  final String status;
  final DateTime createdAt;
  const _ReportControls({
    required this.reportId,
    required this.status,
    required this.createdAt,
  });

  Future<void> _updateStatus(String value) => FirebaseFirestore.instance
      .collection('emergency_reports')
      .doc(reportId)
      .update({'status': value, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Current Status', style: AppTextStyles.titleMd),
                  _StatusChip(status: status, color: _statusColor(status)),
                ],
              ),
              const SizedBox(height: 16),
              _TimelineStep(
                label: 'Submitted',
                active: true,
                time: _formattedDate(createdAt),
              ),
              _TimelineStep(
                label: 'In Progress',
                active: status == 'in_progress' || status == 'resolved',
              ),
              _TimelineStep(label: 'Resolved', active: status == 'resolved'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Actions', style: AppTextStyles.titleMd),
              const SizedBox(height: 12),
              if (status != 'in_progress' && status != 'resolved')
                FilledButton.icon(
                  onPressed: () => _updateStatus('in_progress'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Mark as In Progress'),
                ),
              if (status != 'resolved') ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                  ),
                  onPressed: () => _updateStatus('resolved'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark as Resolved'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant),
    ),
    child: child,
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.bodyMd),
          ],
        ),
      ),
    ],
  );
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool active;
  final String? time;
  const _TimelineStep({required this.label, required this.active, this.time});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(
          active ? Icons.radio_button_checked : Icons.radio_button_off,
          size: 18,
          color: active ? AppColors.primary : AppColors.outlineVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.titleSm),
              if (time != null)
                Text(
                  time!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.replaceAll('_', ' ').toUpperCase(),
      style: AppTextStyles.labelSm.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _EmptyEmergencyState extends StatelessWidget {
  final String message;
  const _EmptyEmergencyState({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Text(
        message,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
      ),
    ),
  );
}

DateTime _createdAt(Map<String, dynamic> data) {
  final value = data['createdAt'];
  return value is Timestamp
      ? value.toDate()
      : DateTime.fromMillisecondsSinceEpoch(0);
}

Color _statusColor(String status) => status == 'resolved'
    ? AppColors.successGreen
    : status == 'in_progress'
    ? AppColors.primary
    : AppColors.error;
String _formattedDate(DateTime value) {
  if (value.year == 1970) return 'Time unavailable';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.month}/${value.day}/${value.year} • $hour:$minute';
}
