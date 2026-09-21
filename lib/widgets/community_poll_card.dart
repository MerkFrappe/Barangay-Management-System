import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/community_polls_screen.dart';

class CommunityPollCard extends StatelessWidget {
  const CommunityPollCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final now = DateTime.now();
        final polls = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          final end = (data['endAt'] as Timestamp?)?.toDate();
          return data['status'] != 'closed' &&
              (end == null || end.isAfter(now));
        }).toList();
        if (polls.isEmpty) return const SizedBox.shrink();
        final data = polls.first.data();
        final choices = List<String>.from(data['choices'] ?? const []);
        final counts = List<int>.from(
          (data['voteCounts'] ?? const []).map(
            (value) => (value as num).toInt(),
          ),
        );
        final total = counts.fold<int>(
          0,
          (runningTotal, voteCount) => runningTotal + voteCount,
        );
        return _pollContent(
          context,
          data['title']?.toString() ?? 'Community Poll',
          choices,
          counts,
          total,
        );
      },
    );
  }

  Widget _pollContent(
    BuildContext context,
    String title,
    List<String> choices,
    List<int> counts,
    int total,
  ) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityPollsScreen()),
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Community Poll',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            choices.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PollOption(
                label: choices[index],
                percentage: total == 0 || index >= counts.length
                    ? 0
                    : counts[index] / total,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PollOption extends StatelessWidget {
  final String label;
  final double percentage;

  const _PollOption({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySm),
            Text(
              '${(percentage * 100).round()}%',
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
