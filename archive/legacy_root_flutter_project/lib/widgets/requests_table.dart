import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum RequestStatus { pending, approved, rejected }

class RequestRow {
  final String initials;
  final String name;
  final String type;
  final String date;
  final RequestStatus status;
  final String actionLabel;

  const RequestRow({
    required this.initials,
    required this.name,
    required this.type,
    required this.date,
    required this.status,
    required this.actionLabel,
  });
}

class RequestsTable extends StatelessWidget {
  const RequestsTable({super.key});

  static const _rows = [
    RequestRow(
        initials: 'RM',
        name: 'Ricardo Mercado',
        type: 'Barangay Clearance',
        date: 'Oct 24, 2023',
        status: RequestStatus.pending,
        actionLabel: 'Review'),
    RequestRow(
        initials: 'ES',
        name: 'Elena Santos',
        type: 'Business Permit',
        date: 'Oct 23, 2023',
        status: RequestStatus.approved,
        actionLabel: 'Details'),
    RequestRow(
        initials: 'JD',
        name: 'Jose Delos Reyes',
        type: 'Indigency Certificate',
        date: 'Oct 23, 2023',
        status: RequestStatus.pending,
        actionLabel: 'Review'),
    RequestRow(
        initials: 'MC',
        name: 'Maria Clara',
        type: 'Barangay Clearance',
        date: 'Oct 22, 2023',
        status: RequestStatus.rejected,
        actionLabel: 'Appeal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Requests',
                    style: AppTextStyles.headlineSm
                        .copyWith(color: AppColors.onSurface)),
                TextButton(
                  onPressed: () {},
                  child: Text('View All Requests',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppColors.surfaceContainerLow),
              dividerThickness: 1,
              columns: [
                DataColumn(label: _header('Resident Name')),
                DataColumn(label: _header('Request Type')),
                DataColumn(label: _header('Date')),
                DataColumn(label: _header('Status')),
                DataColumn(label: _header('Action')),
              ],
              rows: _rows.map((r) => _buildRow(r)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String text) {
    return Text(text,
        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant));
  }

  DataRow _buildRow(RequestRow r) {
    return DataRow(cells: [
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryFixed,
            child: Text(r.initials,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Text(r.name, style: AppTextStyles.labelMd),
        ],
      )),
      DataCell(Text(r.type, style: AppTextStyles.bodySm)),
      DataCell(Text(r.date, style: AppTextStyles.bodySm)),
      DataCell(_StatusChip(status: r.status)),
      DataCell(TextButton(
        onPressed: () {},
        child: Text(r.actionLabel,
            style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
      )),
    ]);
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case RequestStatus.pending:
        bg = AppColors.secondaryFixed;
        fg = AppColors.onSecondaryContainer;
        label = 'Pending';
        break;
      case RequestStatus.approved:
        bg = AppColors.successGreenBg;
        fg = AppColors.successGreen;
        label = 'Approved';
        break;
      case RequestStatus.rejected:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        label = 'Rejected';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
