import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CommunityPollCard extends StatelessWidget {
  const CommunityPollCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Should we schedule a monthly Barangay Cleanup Drive every 1st Saturday?',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _PollOption(label: 'Yes, fully support', percentage: 0.82),
          const SizedBox(height: 8),
          _PollOption(label: 'Prefer Sundays', percentage: 0.18),
        ],
      ),
    );
  }
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
