import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class JurisdictionMap extends StatelessWidget {
  const JurisdictionMap({super.key});

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
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Jurisdiction Map',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('4 UNITS ONLINE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successGreen)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  // Placeholder for the map image/tile in the original design
                  Container(
                    color: AppColors.surfaceVariant,
                    child: Center(
                      child: Icon(Icons.terrain,
                          size: 48,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('REAL-TIME STATUS',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('Zone 2: Peaceful',
                                  style: AppTextStyles.labelSm),
                            ],
                          ),
                        ],
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
