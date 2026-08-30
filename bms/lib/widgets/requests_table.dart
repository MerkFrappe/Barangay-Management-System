import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../screens/admin_documentRequest.dart';

enum RequestStatus { pending, approved, rejected }

class RequestRowData {
  final String initials;
  final String name;
  final String type;
  final String date;
  final RequestStatus status;
  final String actionLabel;

  const RequestRowData({
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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.isEmpty) return 'R';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length > 2 ? 2 : parts[0].length).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    }
    return 'Recent';
  }

  RequestStatus _parseStatus(dynamic rawStatus) {
    final statusStr = (rawStatus ?? 'pending').toString().toLowerCase().trim();
    if (statusStr == 'approved') return RequestStatus.approved;
    if (statusStr == 'rejected') return RequestStatus.rejected;
    return RequestStatus.pending;
  }

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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentRequestScreen()));
                  },
                  child: Text('View All Requests',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outlineVariant),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('document_requests')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No document requests filed yet.',
                        style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                );
              }

              final rowsData = docs.map((doc) {
                final data = doc.data();
                final name = (data['residentName'] ?? 'Resident').toString();
                final type = (data['documentType'] ?? 'Clearance').toString();
                final date = _formatDate(data['createdAt']);
                final status = _parseStatus(data['status']);
                final actionLabel = status == RequestStatus.approved
                    ? 'Details'
                    : (status == RequestStatus.rejected ? 'Appeal' : 'Review');

                return RequestRowData(
                  initials: _getInitials(name),
                  name: name,
                  type: type,
                  date: date,
                  status: status,
                  actionLabel: actionLabel,
                );
              }).toList();

              return SingleChildScrollView(
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
                  rows: rowsData.map((r) => _buildRow(context, r)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _header(String text) {
    return Text(text,
        style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurfaceVariant));
  }

  DataRow _buildRow(BuildContext context, RequestRowData r) {
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
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentRequestScreen()));
        },
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

