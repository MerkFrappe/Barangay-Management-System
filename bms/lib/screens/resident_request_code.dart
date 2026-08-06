import 'package:flutter/material.dart';

void main() {
  runApp(const DocumentRequest());
}

class DocumentRequest extends StatelessWidget {
  const DocumentRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF002576),
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002576),
          primary: const Color(0xFF002576),
          secondary: const Color(0xFF735C00),
          surface: const Color(0xFFF8F9FF),
          onSurface: const Color(0xFF0B1C30),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.02,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.05,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF444653),
          ),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Map<String, Object>> items = [
    {
      'title': 'Water Interruption Notice',
      'date': 'Aug 06, 2026',
      'status': 'Published',
      'color': Color(0xFF15803D),
    },
    {
      'title': 'Community Clean-Up Drive',
      'date': 'Aug 05, 2026',
      'status': 'Draft',
      'color': Color(0xFF735C00),
    },
    {
      'title': 'Health Center Schedule',
      'date': 'Aug 04, 2026',
      'status': 'Published',
      'color': Color(0xFF0038A8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      bottomNavigationBar: !isDesktop ? _buildMobileBottomNav() : null,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDesktop),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildLeftColumn()),
                            const SizedBox(width: 24),
                            Expanded(flex: 5, child: _buildRightColumn()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildLeftColumn(),
                            const SizedBox(height: 24),
                            _buildRightColumn(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Document',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isDesktop ? 32 : 24,
                color: const Color(0xFF002576),
              ),
            ),
            const Text(
              'Submit Documents for Barangay Certifactions and permits online.',
              style: TextStyle(color: Color(0xFF444653)),
            ),
          ],
        ),
        if (isDesktop)
          OutlinedButton.icon(
            onPressed: () => _showPreviewDialog(context),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview Mode'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF002576),
              side: const BorderSide(color: Color(0xFF002576)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFEFF4FF),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barangay HQ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002576),
                  ),
                ),
                Text(
                  'Official Portal',
                  style: TextStyle(fontSize: 12, color: Color(0xFF444653)),
                ),
              ],
            ),
          ),
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _sidebarItem(Icons.groups_outlined, 'Residents', 1),
          _sidebarItem(Icons.description_outlined, 'Services', 2),
          _sidebarItem(Icons.campaign, 'Announcements', 3, isActive: true),
          _sidebarItem(Icons.analytics_outlined, 'Reports', 4),
          const Spacer(),
          const Divider(),
          _sidebarItem(Icons.help_outline, 'Help Center', 5),
          _sidebarItem(Icons.logout, 'Logout', 6),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String label,
    int index, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? const Color(0xFF0038A8) : Colors.transparent,
        leading: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF444653),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF444653),
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        // Recent Announcements Table Card
        Card(
          elevation: 0,
          color: const Color(0xFFEFF4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC4C5D5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _filterChip('All', true),
                        _filterChip('Drafts', false),
                        _filterChip('Published', false),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAnnouncementList(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('View All History'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Stats Grid
      ],
    );
  }

  Widget _buildAnnouncementList() {
    return Column(
      children: items.map((item) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFC4C5D5), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0038A8),
                      ),
                    ),
                    const Text(
                      'Details regarding this...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  item['date'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['status'] as String,
                  style: TextStyle(
                    color: item['color'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRightColumn() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF002576),
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.add_circle_outline, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Name'),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'e.g. Annual Sports Fest',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Date of Birth'),
                          const TextField(
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Address'),
                          const TextField(
                            decoration: InputDecoration(
                              hintText: 'e.g. Annual Sports Fest',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Reason for Request'),
                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe details...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildUploadArea(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Save Draft'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002576),
                          foregroundColor: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Publish Now'),
                        ),
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF444653),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFC4C5D5),
          style: BorderStyle.none,
        ),
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: Color(0xFF747685)),
          SizedBox(height: 8),
          Text(
            'Drop ID here or click to upload',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            'Recommended: 1200x630px',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: textColor.withOpacity(0.5), size: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
        backgroundColor: isSelected
            ? const Color(0xFFD3E4FE)
            : Colors.transparent,
        side: BorderSide.none,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedItemColor: const Color(0xFF735C00),
      unselectedItemColor: const Color(0xFF444653),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002576),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'EVENT',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Annual Community Clean-up',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002576),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join your fellow residents this coming Saturday as we revitalize our community spaces. Tools and refreshments provided.',
                      style: TextStyle(color: Color(0xFF444653)),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF002576)),
                          SizedBox(width: 12),
                          Text(
                            'Main Barangay Plaza',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002576),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Confirm Participation'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
