import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/barangay_official.dart';
import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';

class BarangayOfficialsScreen extends StatelessWidget {
  const BarangayOfficialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop
          ? null
          : const Drawer(
              child: ResidentSidebar(selectedItem: 'Barangay Officials'),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              const ResidentSidebar(selectedItem: 'Barangay Officials'),
            Expanded(
              child: Column(
                children: [
                  const TopNavigationBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: const _OfficialsBody(),
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

class _OfficialsBody extends StatelessWidget {
  const _OfficialsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Barangay Officials',
          style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          'Meet the officials currently serving Barangay Apokon.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isNotEqualTo: 'Resident')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Unable to load officials right now.',
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

            final officials = snapshot.data!.docs
                .map((doc) => BarangayOfficial.fromDoc(doc.id, doc.data()))
                .toList()
              ..sort((a, b) {
                final rankCompare = a.sortRank.compareTo(b.sortRank);
                return rankCompare != 0
                    ? rankCompare
                    : a.name.compareTo(b.name);
              });

            if (officials.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No officials have been added yet.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              );
            }

            final width = MediaQuery.of(context).size.width;
            final columns = width >= 1100
                ? 4
                : width >= 750
                ? 3
                : width >= 480
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: officials.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) =>
                  _OfficialCard(official: officials[index]),
            );
          },
        ),
      ],
    );
  }
}

class _OfficialCard extends StatelessWidget {
  final BarangayOfficial official;
  const _OfficialCard({required this.official});

  @override
  Widget build(BuildContext context) {
    final image = official.imageProvider;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: image,
            child: image == null
                ? Text(
                    official.initials,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            official.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              official.displayTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (official.officeContact != null &&
              official.officeContact!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    official.officeContact!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
