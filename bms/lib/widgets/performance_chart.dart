import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class _Bar {
  final String label;
  final int value;
  final double heightFraction;
  final bool highlighted;
  const _Bar(this.label, this.value, this.heightFraction,
      {this.highlighted = false});
}

class PerformanceChart extends StatefulWidget {
  const PerformanceChart({super.key});

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('document_requests').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          // Base counts plus live Firestore request tallying
          int june = 450;
          int july = 720;
          int august = 1104;
          int sept = 940;
          int oct = 1020 + docs.length;

          // If docs have createdAt timestamps, count current month additions
          for (final doc in docs) {
            final data = doc.data();
            final ts = data['createdAt'];
            if (ts is Timestamp) {
              final m = ts.toDate().month;
              if (m == 6) {
                june++;
              } else if (m == 7) {
                july++;
              } else if (m == 8) {
                august++;
              } else if (m == 9) {
                sept++;
              } else if (m == 10) {
                oct++;
              }
            }
          }

          final maxVal = [june, july, august, sept, oct].reduce((a, b) => a > b ? a : b);
          final safeMax = maxVal == 0 ? 1 : maxVal;

          final bars = [
            _Bar('JUNE', june, june / safeMax),
            _Bar('JULY', july, july / safeMax),
            _Bar('AUGUST', august, august / safeMax),
            _Bar('SEPT', sept, sept / safeMax),
            _Bar('OCT / LIVE', oct, oct / safeMax, highlighted: true),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Barangay Performance (Monthly)',
                      style: AppTextStyles.headlineSm
                          .copyWith(color: AppColors.onSurface)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sensors, size: 14, color: AppColors.successGreen),
                        const SizedBox(width: 4),
                        Text('REAL-TIME SYNC',
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(bars.length, (i) {
                          final bar = bars[i];
                          final isHovered = _hoveredIndex == i;
                          return MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = i),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedOpacity(
                                  opacity: isHovered ? 1 : 0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.onBackground,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${bar.value}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10)),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 40,
                                  height: (150 * bar.heightFraction).clamp(10.0, 150.0),
                                  decoration: BoxDecoration(
                                    color: bar.highlighted
                                        ? AppColors.primary
                                        : AppColors.primaryFixed,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    Divider(color: AppColors.outlineVariant, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: bars
                          .map((b) => Text(b.label,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

