import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';

class DocumentTrackerScreen extends StatelessWidget {
  const DocumentTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop
          ? null
          : const Drawer(child: ResidentSidebar(selectedItem: '')),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) const ResidentSidebar(selectedItem: ''),
            Expanded(
              child: Column(
                children: [
                  const TopNavigationBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: const _TrackerBody(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerBody extends StatelessWidget {
  const _TrackerBody();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Tracker',
          style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          'Check the status of documents you have already requested.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        if (uid == null)
          Text(
            'Sign in to view your requests.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          )
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('document_requests')
                .where('residentId', isEqualTo: uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Unable to load your requests right now.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aTime = a.data()['createdAt'] as Timestamp?;
                  final bTime = b.data()['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); // newest first
                });

              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 40,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "You haven't requested any documents yet.",
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: docs
                    .map(
                      (doc) => _RequestTile(
                        data: doc.data(),
                        docId: doc.id,
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _RequestTile({required this.data, required this.docId});

  @override
  Widget build(BuildContext context) {
    final documentType = (data['documentType'] ?? 'Document').toString();
    final dateSubmitted = (data['dateSubmitted'] ?? '').toString();
    final purpose = (data['purpose'] ?? '').toString();
    final status = (data['status'] ?? 'pending').toString().toLowerCase();

    final statusStyle = _statusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentType,
                  style: AppTextStyles.titleMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (purpose.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    purpose,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (dateSubmitted.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Submitted $dateSubmitted',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusStyle.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusStyle.label,
              style: AppTextStyles.labelSm.copyWith(
                color: statusStyle.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'approved':
      case 'ready':
      case 'completed':
        return _StatusStyle(
          label: 'Approved',
          background: Colors.green.withOpacity(0.12),
          foreground: Colors.green[800]!,
        );
      case 'rejected':
      case 'denied':
        return _StatusStyle(
          label: 'Rejected',
          background: Colors.red.withOpacity(0.12),
          foreground: Colors.red[800]!,
        );
      case 'pending':
      default:
        return _StatusStyle(
          label: 'Pending',
          background: Colors.amber.withOpacity(0.18),
          foreground: Colors.amber[900]!,
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}
