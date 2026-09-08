import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Barangay Help Center',
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How long does a Barangay Clearance take?\nTypically 1–2 business days.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What are the office hours?\nMonday to Friday, 8:00 AM – 5:00 PM.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Official contact\nHotline: +63 917 123 4567\nEmail: help@barangay.gov.ph',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: isWide ? null : AppBar(title: const Text('Help Center')),
      drawer:
          isWide
              ? null
              : const Drawer(
                child: ResidentSidebar(selectedItem: 'Help Center'),
              ),
      body:
          isWide
              ? Row(
                children: [
                  const SizedBox(
                    width: 256,
                    child: ResidentSidebar(selectedItem: 'Help Center'),
                  ),
                  Expanded(child: body),
                ],
              )
              : body,
    );
  }
}
