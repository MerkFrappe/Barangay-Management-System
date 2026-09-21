import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/residence_announcements.dart';
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
          children: [
            Expanded(
              child: Text(
                'Latest News & Events',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMd,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CivicHorizonApp()),
              ),
              child: const Text('See all'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .where('status', isEqualTo: 'published')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!.docs.toList()
              ..sort((a, b) {
                final aPin = a.data()['isPinned'] == true ? 1 : 0;
                final bPin = b.data()['isPinned'] == true ? 1 : 0;
                if (aPin != bPin) return bPin.compareTo(aPin);
                final aDate =
                    (a.data()['createdAt'] as Timestamp?)
                        ?.millisecondsSinceEpoch ??
                    0;
                final bDate =
                    (b.data()['createdAt'] as Timestamp?)
                        ?.millisecondsSinceEpoch ??
                    0;
                return bDate.compareTo(aDate);
              });
            if (items.isEmpty) {
              return const Text(
                'No current announcements have been published.',
              );
            }
            return Column(
              children: items.take(3).map((doc) {
                final item = doc.data();
                final category = item['category']?.toString() ?? 'News';
                final created = (item['createdAt'] as Timestamp?)?.toDate();
                final imageList = item['imageBase64List'];
                final image = imageList is List && imageList.isNotEmpty
                    ? imageList.first.toString()
                    : item['coverImageBase64']?.toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: NewsCard(
                    category: item['isPinned'] == true
                        ? 'Pinned · $category'
                        : category,
                    date: created == null
                        ? 'Just published'
                        : '${created.month}/${created.day}/${created.year}',
                    imageIcon: _categoryIcon(category),
                    imageBase64: image,
                    title: item['title']?.toString() ?? 'Announcement',
                    description: item['description']?.toString() ?? '',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CivicHorizonApp(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  IconData _categoryIcon(String category) => switch (category) {
    'emergency' => Icons.warning_amber_rounded,
    'event' => Icons.event,
    'officialMemo' => Icons.description_outlined,
    _ => Icons.campaign_outlined,
  };
}
