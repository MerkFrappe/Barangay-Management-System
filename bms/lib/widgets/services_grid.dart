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
        LayoutBuilder(
          builder: (context, constraints) {
            // The available width is smaller than the screen width when this
            // widget is beside the resident sidebar.  Base the grid on these
            // constraints so cards never get squeezed into an undersized row.
            final twoColumns = constraints.maxWidth >= 620;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: twoColumns ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // ServiceCard has several text lines and an action.  A taller
              // tile prevents the Column inside it from overflowing.
              childAspectRatio: twoColumns ? 1.15 : 1.3,
              children: const [
                ServiceCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.primary,
                  iconBackground: AppColors.primaryFixed,
                  title: 'E- Services',
                  description:
                      'Apply online for official barangay clearance certificate.',
                  buttonText: 'Apply Now',
                ),
                ServiceCard(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.secondary,
                  iconBackground: AppColors.secondaryFixed,
                  title: 'Get an Event',
                  description: 'Request official proof of residency document.',
                  buttonText: 'Request Document',
                ),
                ServiceCard(
                  icon: Icons.volunteer_activism_outlined,
                  iconColor: AppColors.tertiary,
                  iconBackground: AppColors.tertiaryFixed,
                  title: 'Document Tracker',
                  description:
                      'Access social services and financial aid support.',
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
            );
          },
        ),
      ],
    );
  }
}
