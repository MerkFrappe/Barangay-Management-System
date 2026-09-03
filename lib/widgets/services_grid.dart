import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/resident_request_code.dart';
import '../screens/document_tracker_screen.dart';
import '../screens/report_incident_screen.dart';
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
              children: [
                // Barangay Clearance application.
                ServiceCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.primary,
                  iconBackground: AppColors.primaryFixed,
                  title: 'E-Services',
                  description:
                      'Apply online for official barangay clearance certificate.',
                  buttonText: 'Apply Now',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DocumentRequest()),
                  ),
                ),
                // Was "Get an Event" — title didn't match its own
                // description or icon, which were both about a residency
                // document. Renamed to match what it actually does.
                ServiceCard(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.secondary,
                  iconBackground: AppColors.secondaryFixed,
                  title: 'Certificate of Residency',
                  description:
                      'Request an official proof-of-residency document.',
                  buttonText: 'Request Document',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DocumentRequest()),
                  ),
                ),
                // Was described as social/financial aid — that's not what a
                // tracker does. Now points to an actual status view of the
                // resident's own submitted requests.
                ServiceCard(
                  icon: Icons.fact_check_outlined,
                  iconColor: AppColors.tertiary,
                  iconBackground: AppColors.tertiaryFixed,
                  title: 'Document Tracker',
                  description:
                      'Check the status of documents you have already requested.',
                  buttonText: 'View Status',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DocumentTrackerScreen(),
                    ),
                  ),
                ),
                ServiceCard(
                  icon: Icons.report_problem_outlined,
                  iconColor: AppColors.error,
                  iconBackground: AppColors.errorContainer,
                  title: 'File Incident / Complaint',
                  description:
                      'Submit blotter or community incident reports securely.',
                  buttonText: 'Report Incident',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportIncidentScreen(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
