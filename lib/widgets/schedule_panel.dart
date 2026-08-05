import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class _ScheduleItem {
  final String time;
  final String period;
  final String title;
  final String location;
  final bool dimmed;
  const _ScheduleItem(this.time, this.period, this.title, this.location,
      {this.dimmed = false});
}

class SchedulePanel extends StatelessWidget {
  const SchedulePanel({super.key});

  static const _items = [
    _ScheduleItem('09:00', 'AM', 'Peace & Order Council', 'Session Hall, Brgy. Hall'),
    _ScheduleItem('14:30', 'PM', 'Community Pantry Visit', 'Zone 3 Distribution Point'),
    _ScheduleItem('17:00', 'PM', 'Document Signing', 'Admin Office', dimmed: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Schedule',
                          style: AppTextStyles.headlineSm
                              .copyWith(color: AppColors.onPrimary)),
                      Icon(Icons.event, color: AppColors.onPrimary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Oct 24, 2023',
                      style: AppTextStyles.headlineMd
                          .copyWith(color: AppColors.onPrimary)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  for (final item in _items) ...[
                    _ScheduleTile(item: item),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.surfaceContainer,
                child: Text(
                  'View Full Calendar',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final _ScheduleItem item;
  const _ScheduleTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeColor = item.dimmed ? AppColors.onSurfaceVariant : AppColors.primary;
    final titleColor = item.dimmed ? AppColors.onSurfaceVariant : AppColors.primary;
    return Opacity(
      opacity: item.dimmed ? 0.6 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(item.time,
                    style: AppTextStyles.labelSm
                        .copyWith(color: timeColor, fontWeight: FontWeight.bold)),
                Text(item.period,
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: titleColor)),
                  const SizedBox(height: 2),
                  Text(item.location,
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
