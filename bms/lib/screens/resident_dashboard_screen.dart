import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/resident_sidebar.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/services_grid.dart';
import '../widgets/news_section.dart';
import '../widgets/emergency_card.dart';
import '../widgets/community_poll_card.dart';
import '../widgets/did_you_know_card.dart';
import '../widgets/footer_section.dart';

class ResidentDashboardScreen extends StatelessWidget {
  const ResidentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final desktop = width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: desktop ? null : const Drawer(child: ResidentSidebar()),

      body: SafeArea(
        child: Row(
          children: [
            //-----------------------------------
            // LEFT SIDEBAR
            //-----------------------------------
            if (desktop) const ResidentSidebar(),

            //-----------------------------------
            // MAIN CONTENT
            //-----------------------------------
            Expanded(
              child: Column(
                children: [
                  const TopNavigationBar(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),

                          child: desktop
                              ? const _DesktopLayout()
                              : const _MobileLayout(),
                        ),
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

////////////////////////////////////////////////////////////
///
/// DESKTOP
///
////////////////////////////////////////////////////////////

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeroBanner(),

        const SizedBox(height: 32),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---------------------------------
            // LEFT CONTENT
            //---------------------------------
            const Expanded(
              flex: 8,
              child: Column(
                children: [ServicesGrid(), SizedBox(height: 30), NewsSection()],
              ),
            ),

            const SizedBox(width: 24),

            //---------------------------------
            // RIGHT CONTENT
            //---------------------------------
            const Expanded(
              flex: 4,
              child: Column(
                children: [
                  EmergencyCard(),

                  SizedBox(height: 20),

                  CommunityPollCard(),

                  SizedBox(height: 20),

                  DidYouKnowCard(),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        const FooterSection(),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
///
/// MOBILE
///
////////////////////////////////////////////////////////////

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HeroBanner(),

        SizedBox(height: 24),

        ServicesGrid(),

        SizedBox(height: 24),

        EmergencyCard(),

        SizedBox(height: 24),

        CommunityPollCard(),

        SizedBox(height: 24),

        DidYouKnowCard(),

        SizedBox(height: 24),

        NewsSection(),

        SizedBox(height: 40),

        FooterSection(),
      ],
    );
  }
}
