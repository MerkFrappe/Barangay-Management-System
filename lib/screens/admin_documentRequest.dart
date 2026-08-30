import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';

typedef AdminDocumentRequestScreen = admin_documentRequest;

class admin_documentRequest extends StatefulWidget {
  const admin_documentRequest({super.key});

  @override
  State<admin_documentRequest> createState() => _admin_documentRequestState();
}

class _admin_documentRequestState extends State<admin_documentRequest> {
  String _searchQuery = '';
  String _selectedStatus = 'All Statuses';

  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'document_requests',
  );

  String _normalizedStatus(dynamic value) {
    final status = (value ?? 'Pending').toString().trim().toLowerCase();
    switch (status) {
      case 'in review':
        return 'In Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  String _requesterFullName(Map<String, dynamic> data) {
    final snapshot = data['requesterSnapshot'];
    if (snapshot is Map) {
      final name = snapshot['fullName']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }
    // Retain a readable name for requests created before requesterSnapshot.
    return data['residentName']?.toString() ?? 'N/A';
  }

  void _showStatusUpdateDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        String currentStatus = _normalizedStatus(data['status']);
        return AlertDialog(
          title: Text(
            'Update Request Status',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resident: ${_requesterFullName(data)}',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 8),
              Text(
                'Document: ${data['documentType'] ?? 'N/A'}',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 8),
              Text(
                'Purpose: ${data['purpose'] ?? 'N/A'}',
                style: AppTextStyles.bodyMd,
              ),
              if ((data['address'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Address: ${data['address']}',
                  style: AppTextStyles.bodyMd,
                ),
              ],
              if ((data['idAttachmentName'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Attached ID: ${data['idAttachmentName']}',
                  style: AppTextStyles.bodyMd,
                ),
              ],
              const SizedBox(height: 16),
              const Text('Select new status:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Pending', 'In Review', 'Approved', 'Rejected'].map((
                  status,
                ) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: currentStatus == status,
                    onSelected: (selected) {
                      if (selected) {
                        _collection.doc(docId).update({'status': status}).then((
                          _,
                        ) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status updated to $status'),
                            ),
                          );
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenIsWide = constraints.maxWidth >= 1024;
        final isMobile = !screenIsWide;

        final body = Column(
          children: [
            TopHeader(
              onSearchChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Requests',
                                    style: AppTextStyles.headlineLg.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Review and process resident document applications like clearances and certificates.',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Filters
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Requests Database',
                              style: AppTextStyles.headlineSm.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedStatus,
                              items:
                                  [
                                        'All Statuses',
                                        'Pending',
                                        'In Review',
                                        'Approved',
                                        'Rejected',
                                      ]
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedStatus = val!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Table
                        Card(
                          elevation: 0,
                          color: AppColors.surfaceContainerLowest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: AppColors.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _collection
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final docs = snapshot.data?.docs ?? [];
                                final filteredDocs = docs.where((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  // Status filter
                                  if (_selectedStatus != 'All Statuses') {
                                    if (_normalizedStatus(data['status']) !=
                                        _selectedStatus) {
                                      return false;
                                    }
                                  }

                                  // Search filter
                                  if (_searchQuery.isNotEmpty) {
                                    final searchLower = _searchQuery
                                        .toLowerCase();
                                    final name = _requesterFullName(
                                      data,
                                    ).toLowerCase();
                                    final id = doc.id.toLowerCase();
                                    final type = (data['documentType'] ?? '')
                                        .toLowerCase();
                                    if (!name.contains(searchLower) &&
                                        !id.contains(searchLower) &&
                                        !type.contains(searchLower)) {
                                      return false;
                                    }
                                  }

                                  return true;
                                }).toList();

                                if (filteredDocs.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Text(
                                        'No requests found matching your filters.',
                                      ),
                                    ),
                                  );
                                }

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Request ID')),
                                      DataColumn(label: Text('Resident Name')),
                                      DataColumn(label: Text('Document Type')),
                                      DataColumn(label: Text('Date Submitted')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Action')),
                                    ],
                                    rows: filteredDocs.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final status = _normalizedStatus(
                                        data['status'],
                                      );

                                      Color statusBg =
                                          AppColors.primaryContainer;
                                      Color statusText = AppColors.onPrimary;
                                      if (status == 'Approved') {
                                        statusBg = AppColors.successGreenBg;
                                        statusText = AppColors.successGreen;
                                      } else if (status == 'Rejected') {
                                        statusBg = AppColors.errorContainer;
                                        statusText = AppColors.error;
                                      } else if (status == 'Pending') {
                                        statusBg = AppColors.secondaryContainer;
                                        statusText = AppColors.secondary;
                                      }

                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              'REQ-${doc.id.substring(0, doc.id.length < 5 ? doc.id.length : 5).toUpperCase()}',
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              _requesterFullName(data),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(data['documentType'] ?? 'N/A'),
                                          ),
                                          DataCell(
                                            Text(
                                              data['dateSubmitted'] ?? 'N/A',
                                            ),
                                          ),
                                          DataCell(
                                            Chip(
                                              label: Text(status),
                                              labelStyle: TextStyle(
                                                color: statusText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              backgroundColor: statusBg,
                                              side: BorderSide.none,
                                            ),
                                          ),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _showStatusUpdateDialog(
                                                    context,
                                                    doc.id,
                                                    data,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    AppColors.primaryContainer,
                                                foregroundColor:
                                                    AppColors.onPrimary,
                                              ),
                                              child: const Text('Update'),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: isMobile
              ? const Drawer(child: SidebarNav(selectedIndex: 2))
              : null,
          body: Row(
            children: [
              if (!isMobile) const SidebarNav(selectedIndex: 2),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
