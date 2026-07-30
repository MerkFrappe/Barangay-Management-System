import 'package:flutter/material.dart';

void main() {
  runApp(const BarangayConnectApp());
}

class BarangayConnectApp extends StatelessWidget {
  const BarangayConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002576),
          primary: const Color(0xFF002576),
          secondary: const Color(0xFF735C00),
          error: const Color(0xFFBA1A1A),
          surface: const Color(0xFFF8F9FF),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.description_outlined, 'label': 'Barangay Clearance'},
    {
      'icon': Icons.assignment_ind_outlined,
      'label': 'Certificate of Indigency',
    },
    {'icon': Icons.business_center_outlined, 'label': 'Business Permit'},
    {'icon': Icons.badge_outlined, 'label': 'Community ID'},
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      'tag': 'Community Event',
      'tagColor': Color(0xFF002576),
      'tagTextColor': Colors.white,
      'title': 'Upcoming Clean-up Drive',
      'description':
          'Join us this Saturday, 7:00 AM at the Barangay Plaza. Let\'s keep San Jose clean!',
      'date': 'Oct 24, 2023',
      'color': Color(0xFFD3E4FE),
    },
    {
      'tag': 'Health Alert',
      'tagColor': Color(0xFF8C0014),
      'tagTextColor': Color(0xFFFFB3AE),
      'title': 'Vaccination Schedule',
      'description':
          'Free flu shots available for senior citizens this coming Wednesday at the Health Center.',
      'date': 'Oct 27, 2023',
      'color': Color(0xFFFFDAD7),
    },
  ];

  //SQL DATABASE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 16),
            _buildEmergencyButton(),
            const SizedBox(height: 16),
            _buildQuickServices(),
            const SizedBox(height: 16),
            _buildAnnouncements(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFDCE1FF),
            child: ClipOval(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB1YXm9Ylz2jn_pE95BUUaOKBlodEzPAWiZSyYpxW8XqiohRAz4Uw2ZitrH5FUBNgVQq5jg7oA7AiVQFY50Y52PR3T80nZl8bf2o7exumNMFBbEzd89yZh3AN-9IVnzYosGGgAUdUilznDWRVw7guOmdbSPfODKNZo3uv9OxKtPtZ6xsvIs6gNUm-hRU_g_zXoau6LNmFr664JJHtG5FZhcAbS6xHg2sLZ-4McJ_LjPjAzEIGXLPCA-',
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shield,
                  color: Color(0xFF002576),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Barangay Connect',
            style: TextStyle(
              color: Color(0xFF002576),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Color(0xFF002576),
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF002576),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002576).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome, Resident!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your digital gateway to Barangay San Jose. Access services and community updates in one tap.',
            style: TextStyle(
              color: Color(0xFF96ADFF),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFECC00),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Verified Resident',
              style: TextStyle(
                color: Color(0xFF6E5700),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          border: Border.all(color: const Color(0xFFBA1A1A), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFBA1A1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMERGENCY RESPONSE',
                    style: TextStyle(
                      color: Color(0xFF93000A),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quick contact for Brgy. Emergency Team',
                    style: TextStyle(
                      color: Color(0xFF93000A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF93000A)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Services',
              style: TextStyle(
                color: Color(0xFF002576),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF002576),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: _quickServices
              .map(
                (service) => _buildServiceCard(
                  icon: service['icon'] as IconData,
                  label: service['label'] as String,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard({required IconData icon, required String label}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC4C5D5)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE9FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF002576), size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0B1C30),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Announcements',
          style: TextStyle(
            color: Color(0xFF002576),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _announcements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _announcements[index];
              return _buildAnnouncementCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> item) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC4C5D5)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: item['color'] as Color,
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item['tagColor'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['tag'] as String,
                      style: TextStyle(
                        color: item['tagTextColor'] as Color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF444653),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF002576),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['date'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF002576),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.apps, 'label': 'Services'},
      {'icon': Icons.description_outlined, 'label': 'Requests'},
      {'icon': Icons.notifications_outlined, 'label': 'Alerts'},
    ];

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFECC00) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isActive
                            ? const Color(0xFF6E5700)
                            : const Color(0xFF444653),
                        size: 24,
                      ),
                      if (index == 3)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBA1A1A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF6E5700)
                          : const Color(0xFF444653),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
