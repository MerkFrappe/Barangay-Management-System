import 'package:flutter/material.dart';
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

  static const _bars = [
    _Bar('JUNE', 450, 0.25),
    _Bar('JULY', 720, 0.5),
    _Bar('AUGUST', 1104, 0.83, highlighted: true),
    _Bar('SEPT', 940, 0.67),
    _Bar('OCT', 1020, 0.75),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Barangay Performance (Monthly)',
              style: AppTextStyles.headlineSm
                  .copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_bars.length, (i) {
                      final bar = _bars[i];
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
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 150 * bar.heightFraction,
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
                  children: _bars
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
      ),
    );
  }
}
