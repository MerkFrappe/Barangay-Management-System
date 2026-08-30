import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'news_card.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //------------------------------------------
        // HEADER
        //------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Latest News & Events", style: AppTextStyles.headlineMd),

            TextButton(onPressed: () {}, child: const Text("See All News")),
          ],
        ),

        const SizedBox(height: 24),

        //------------------------------------------
        // NEWS
        //------------------------------------------
        NewsCard(
          category: "Environment",

          date: "May 21, 2024",

          imageIcon: Icons.park,

          title: "Community Tree Planting: Green Horizon 2024",

          description:
              "Join us this weekend for our annual tree planting event. Tools and seedlings will be provided.",

          onTap: () {},
        ),

        const SizedBox(height: 20),

        NewsCard(
          category: "Governance",

          date: "May 19, 2024",

          imageIcon: Icons.account_balance,

          title: "Barangay Digital Portal Phase 2 Launch",

          description:
              "Accessing permits just got faster. Discover the newest features of our digital resident portal.",

          onTap: () {},
        ),
      ],
    );
  }
}
