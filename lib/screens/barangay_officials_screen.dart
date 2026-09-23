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
      bottomNavigationBar: desktop
          ? null
          : const ResidentMobileNavigation(currentIndex: 1),
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

            final officials =
                snapshot.data!.docs
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

            return _OfficialsHierarchy(officials: officials);
          },
        ),
      ],
    );
  }
}

/// An organisation chart: senior officials are at the top and the officers
/// reporting to them branch below, like an upside-down tree.
class _OfficialsHierarchy extends StatelessWidget {
  final List<BarangayOfficial> officials;
  const _OfficialsHierarchy({required this.officials});

  @override
  Widget build(BuildContext context) {
    final byId = {for (final official in officials) official.id: official};
    String? parentIdOf(BarangayOfficial official) {
      final value = official.reportsTo?.trim();
      if (value == null || value.isEmpty) {
        // Preserve the intended relationship for the existing staff record
        // until it is saved explicitly in Settings.
        if (official.name.toLowerCase().contains('yuichi') &&
            official.name.toLowerCase().contains('satoh')) {
          for (final candidate in officials) {
            if (candidate.name.toLowerCase().contains('lawrenz') &&
                candidate.name.toLowerCase().contains('mesiona')) {
              return candidate.id;
            }
          }
        }
        return null;
      }
      if (byId.containsKey(value)) return value;
      final name = value.toLowerCase();
      for (final candidate in officials) {
        if (candidate.name.trim().toLowerCase() == name) return candidate.id;
      }
      return null;
    }
    final roots = officials.where((official) => parentIdOf(official) == null).toList();
    final levels = <List<BarangayOfficial>>[];
    final seen = <String>{};
    var level = roots;
    while (level.isNotEmpty) {
      levels.add(level);
      seen.addAll(level.map((official) => official.id));
      level = officials
          .where((official) =>
              !seen.contains(official.id) &&
              level.any((parent) => parentIdOf(official) == parent.id))
          .toList();
    }
    // Keep malformed/cyclic records visible instead of making them disappear.
    final remaining = officials.where((official) => !seen.contains(official.id)).toList();
    if (remaining.isNotEmpty) levels.add(remaining);

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          for (var index = 0; index < levels.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(width: 2, height: 18, color: AppColors.outlineVariant),
                    Container(
                      height: 2,
                      width: (levels[index].length * 120.0)
                          .clamp(80.0, constraints.maxWidth)
                          .toDouble(),
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: levels[index]
                  .map((official) => SizedBox(
                        width: constraints.maxWidth < 600 ? 220 : 250,
                        height: 260,
                        child: _OfficialCard(official: official),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
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
