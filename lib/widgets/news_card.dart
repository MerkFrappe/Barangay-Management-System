import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NewsCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String date;
  final IconData imageIcon;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.date,
    required this.imageIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Card(
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------
            // IMAGE PLACEHOLDER
            //------------------------------------------------
            Container(
              width: compact ? 116 : 170,
              height: compact ? 190 : 170,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
              ),
              child: Icon(imageIcon, size: 60, color: Colors.white),
            ),

            //------------------------------------------------
            // CONTENT
            //------------------------------------------------
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(compact ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          date,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      title,
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
