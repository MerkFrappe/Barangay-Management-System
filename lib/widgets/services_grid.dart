import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'service_card.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Resident Services',
          style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width >= 700 ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: const [
            ServiceCard(
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.primary,
              iconBackground: AppColors.primaryFixed,
              title: 'Barangay Clearance',
              description:
                  'Apply online for official barangay clearance certificate.',
              buttonText: 'Apply Now',
            ),
            ServiceCard(
              icon: Icons.description_outlined,
              iconColor: AppColors.secondary,
              iconBackground: AppColors.secondaryFixed,
              title: 'Certificate of Residency',
              description: 'Request official proof of residency document.',
              buttonText: 'Request Document',
            ),
            ServiceCard(
              icon: Icons.volunteer_activism_outlined,
              iconColor: AppColors.tertiary,
              iconBackground: AppColors.tertiaryFixed,
              title: 'Certificate of Indigency',
              description: 'Access social services and financial aid support.',
              buttonText: 'File Request',
            ),
            ServiceCard(
              icon: Icons.report_problem_outlined,
              iconColor: AppColors.error,
              iconBackground: AppColors.errorContainer,
              title: 'File Incident / Complaint',
              description:
                  'Submit blotter or community incident reports securely.',
              buttonText: 'Report Incident',
            ),
          ],
        ),
      ],
    );
  }
}
