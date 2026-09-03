import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../screens/resident_request_code.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(desktop ? 40 : 28),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          //----------------------------------------
          // Decorative circles
          //----------------------------------------
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            right: 80,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .04),
              ),
            ),
          ),

          //----------------------------------------
          // Content
          //----------------------------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Wednesday, May 22, 2024",
                style: AppTextStyles.labelMd.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "Good Evening, Neighbor!",
                style: AppTextStyles.headlineLg.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 18),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  "Your digital bridge to Barangay services and community updates. "
                  "How can we help improve our neighborhood today?",
                  style: AppTextStyles.bodyLg.copyWith(
                    color: Colors.white.withValues(alpha: .90),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {},

                    icon: const Icon(Icons.report_problem),

                    label: const Text("Report an Issue"),
                  ),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .35),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DocumentRequest(),
                        ),
                      );
                    },

                    child: const Text("View My Requests"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
