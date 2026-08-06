import 'package:flutter/material.dart';

// ─── Entry Point ─────────────────────────────────────────────────────────────

void main() {
  runApp(const BarangayHQApp());
}

class BarangayHQApp extends StatelessWidget {
  const BarangayHQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay HQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002576)),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AnnouncementPage(),
    );
  }
}

// ─── Model ───────────────────────────────────────────────────────────────────

enum AnnouncementStatus { published, draft, scheduled }

enum AnnouncementCategory { news, emergency, event, officialMemo }

class Announcement {
  final String id;
  final String title;
  final String description;
  final String date;
  final AnnouncementCategory category;
  final AnnouncementStatus status;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.status,
  });
}

// ─── Fake Database Service ────────────────────────────────────────────────────
// Simulates network latency. To connect to a real backend:
//   fetchAnnouncements() → replace with: http.get(Uri.parse('$baseUrl/announcements'))
//   saveAnnouncement()   → replace with: http.post(Uri.parse('$baseUrl/announcements'), body: ...)
//   deleteAnnouncement() → replace with: http.delete(Uri.parse('$baseUrl/announcements/$id'))

class AnnouncementService {
  static final List<Announcement> _db = [
    Announcement(
      id: '1',
      title: 'Barangay Clean-up Drive',
      description: 'Join us this Saturday for our monthly...',
      date: 'Oct 24, 2023',
      category: AnnouncementCategory.event,
      status: AnnouncementStatus.published,
    ),
    Announcement(
      id: '2',
      title: 'Heavy Rain Warning',
      description: 'Low pressure area detected near...',
      date: 'Oct 23, 2023',
      category: AnnouncementCategory.emergency,
      status: AnnouncementStatus.published,
    ),
    Announcement(
      id: '3',
      title: 'New Health Center Hours',
      description: 'Starting next month, we will be...',
      date: 'Oct 20, 2023',
      category: AnnouncementCategory.news,
      status: AnnouncementStatus.draft,
    ),
    Announcement(
      id: '4',
      title: 'Senior Citizen Payout',
      description: 'Quarterly social pension distribution...',
      date: 'Oct 18, 2023',
      category: AnnouncementCategory.event,
      status: AnnouncementStatus.scheduled,
    ),
  ];

  static Future<List<Announcement>> fetchAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_db);
  }

  static Future<Announcement> saveAnnouncement(Announcement a) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _db.insert(0, a);
    return a;
  }

  static Future<void> deleteAnnouncement(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _db.removeWhere((a) => a.id == id);
  }
}

// ─── Main Page ───────────────────────────────────────────────────────────────

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  int _selectedNav = 3;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.groups_outlined, label: 'Residents'),
    _NavItem(icon: Icons.description_outlined, label: 'Services'),
    _NavItem(icon: Icons.campaign_outlined, label: 'Announcements'),
    _NavItem(icon: Icons.analytics_outlined, label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Row(
        children: [
          _Sidebar(
            items: _navItems,
            selectedIndex: _selectedNav,
            onTap: (i) => setState(() => _selectedNav = i),
          ),
          const Expanded(child: _MainContent()),
        ],
      ),
    );
  }
}

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _Sidebar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFFEFF4FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barangay HQ',
                  style: TextStyle(
                    color: Color(0xFF002576),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Official Portal',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFC4C5D5)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final isActive = selectedIndex == i;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0038A8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[i].icon,
                          size: 20,
                          color: isActive
                              ? const Color(0xFF96ADFF)
                              : const Color(0xFF444653),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF444653),
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFC4C5D5)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _SidebarFooterItem(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                ),
                const SizedBox(height: 4),
                _SidebarFooterItem(icon: Icons.logout, label: 'Logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SidebarFooterItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF444653)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF444653), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
            color: Colors.white,
          ),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Announcement Management',
                    style: TextStyle(
                      color: Color(0xFF002576),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Draft, schedule, and broadcast community updates.',
                    style: TextStyle(color: Color(0xFF444653), fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Preview Mode'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF002576),
                  side: const BorderSide(color: Color(0xFF002576)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 7, child: _LeftColumn()),
                SizedBox(width: 20),
                SizedBox(width: 360, child: _AddEventForm()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Left Column ─────────────────────────────────────────────────────────────

class _LeftColumn extends StatefulWidget {
  const _LeftColumn();

  @override
  State<_LeftColumn> createState() => _LeftColumnState();
}

class _LeftColumnState extends State<_LeftColumn> {
  late Future<List<Announcement>> _future;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _future = AnnouncementService.fetchAnnouncements();
  }

  void refresh() => setState(() {
    _future = AnnouncementService.fetchAnnouncements();
  });

  List<Announcement> _applyFilter(List<Announcement> all) {
    if (_filter == 'Drafts')
      return all.where((a) => a.status == AnnouncementStatus.draft).toList();
    if (_filter == 'Published')
      return all
          .where((a) => a.status == AnnouncementStatus.published)
          .toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC4C5D5)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    const Spacer(),
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'All',
                      onTap: () => setState(() => _filter = 'All'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Drafts',
                      selected: _filter == 'Drafts',
                      onTap: () => setState(() => _filter = 'Drafts'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Published',
                      selected: _filter == 'Published',
                      onTap: () => setState(() => _filter = 'Published'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Announcement>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF002576),
                          ),
                        ),
                      );
                    }
                    if (snap.hasError)
                      return Center(child: Text('Error: ${snap.error}'));
                    final items = _applyFilter(snap.data!);
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No announcements found.',
                            style: TextStyle(color: Color(0xFF747685)),
                          ),
                        ),
                      );
                    }
                    return _AnnouncementsTable(
                      items: items,
                      onDeleted: refresh,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All History',
                      style: TextStyle(
                        color: Color(0xFF002576),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(
                label: 'Total Published',
                value: '128',
                icon: Icons.campaign_outlined,
                dark: true,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Total Reach',
                value: '4.2k',
                icon: Icons.visibility_outlined,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Avg. Engagement',
                value: '82%',
                icon: Icons.trending_up,
                accentColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD3E4FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF002576) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? const Color(0xFF002576) : const Color(0xFF444653),
          ),
        ),
      ),
    );
  }
}

// ─── Table ────────────────────────────────────────────────────────────────────

class _AnnouncementsTable extends StatelessWidget {
  final List<Announcement> items;
  final VoidCallback onDeleted;
  const _AnnouncementsTable({required this.items, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFC4C5D5))),
          ),
          children: ['Title', 'Date', 'Category', 'Status', 'Actions']
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    h,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444653),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...items.map((a) => _buildRow(context, a)),
      ],
    );
  }

  TableRow _buildRow(BuildContext context, Announcement a) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5EEFF))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF002576),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                a.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF444653)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            a.date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF444653)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _CategoryBadge(category: a.category),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: _StatusBadge(status: a.status),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: Color(0xFF444653),
            ),
            onSelected: (value) async {
              if (value == 'delete') {
                await AnnouncementService.deleteAnnouncement(a.id);
                onDeleted();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${a.title}" deleted.'),
                      backgroundColor: const Color(0xFF002576),
                    ),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final AnnouncementCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final map = {
      AnnouncementCategory.event: (
        'Event',
        const Color(0xFFD3E4FE),
        const Color(0xFF002576),
      ),
      AnnouncementCategory.emergency: (
        'Emergency',
        const Color(0xFF8C0014),
        const Color(0xFFFF918B),
      ),
      AnnouncementCategory.news: (
        'News',
        const Color(0xFFD3E4FE),
        const Color(0xFF002576),
      ),
      AnnouncementCategory.officialMemo: (
        'Official Memo',
        const Color(0xFFFFE089),
        const Color(0xFF574500),
      ),
    };
    final (label, bg, fg) = map[category]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AnnouncementStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      AnnouncementStatus.published: (
        'PUBLISHED',
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      AnnouncementStatus.draft: (
        'DRAFT',
        const Color(0xFFFECC00),
        const Color(0xFF6E5700),
      ),
      AnnouncementStatus.scheduled: (
        'SCHEDULED',
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
      ),
    };
    final (label, bg, fg) = map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool dark;
  final Color? accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.dark = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF002576) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC4C5D5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark ? const Color(0xFF96ADFF) : const Color(0xFF444653),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : const Color(0xFF002576),
                  ),
                ),
                Icon(
                  icon,
                  size: 32,
                  color:
                      accentColor ??
                      (dark
                          ? Colors.white.withOpacity(0.4)
                          : const Color(0xFFFECC00)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Event Form ───────────────────────────────────────────────────────────

class _AddEventForm extends StatefulWidget {
  const _AddEventForm();

  @override
  State<_AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<_AddEventForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AnnouncementCategory _category = AnnouncementCategory.news;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF002576)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit(AnnouncementStatus status) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title.')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final a = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? 'No description provided.'
          : _descController.text.trim(),
      date: _selectedDate != null
          ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
          : 'No date set',
      category: _category,
      status: status,
    );

    // 👉 Swap this with http.post() to save to a real Laravel/Express backend
    await AnnouncementService.saveAnnouncement(a);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == AnnouncementStatus.published
                ? '"${a.title}" published!'
                : '"${a.title}" saved as draft.',
          ),
          backgroundColor: const Color(0xFF002576),
        ),
      );
      _titleController.clear();
      _descController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _category = AnnouncementCategory.news;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C5D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF002576),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Text(
                  'Add New Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.add_circle_outline, color: Colors.white),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormLabel('Event Title'),
                const SizedBox(height: 6),
                _FormField(
                  controller: _titleController,
                  hint: 'e.g., Annual Sports Fest 2023',
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormLabel('Date'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickDate,
                            child: _PickerField(
                              icon: Icons.calendar_today,
                              label: _selectedDate != null
                                  ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                                  : 'Pick date',
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
                          _FormLabel('Time'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickTime,
                            child: _PickerField(
                              icon: Icons.access_time,
                              label: _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : 'Pick time',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _FormLabel('Category'),
                const SizedBox(height: 6),
                DropdownButtonFormField<AnnouncementCategory>(
                  value: _category,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF747685)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF002576),
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AnnouncementCategory.news,
                      child: Text('News'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementCategory.emergency,
                      child: Text('Emergency'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementCategory.event,
                      child: Text('Event'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementCategory.officialMemo,
                      child: Text('Official Memo'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                _FormLabel('Description'),
                const SizedBox(height: 6),
                _FormField(
                  controller: _descController,
                  hint: 'Describe the details of the announcement...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                _FormLabel('Cover Image'),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC4C5D5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8F9FF),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: Color(0xFF747685),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Drop image here or click to upload',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444653),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Recommended: 1200x630px',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF747685),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF4FF),
              border: Border(top: BorderSide(color: Color(0xFFC4C5D5))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _submit(AnnouncementStatus.draft),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF002576),
                      side: const BorderSide(color: Color(0xFF002576)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Draft',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _submit(AnnouncementStatus.published),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002576),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Publish Now',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form helpers ─────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444653),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF747685), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF747685)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF002576), width: 2),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PickerField({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF747685)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF444653)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF444653)),
          ),
        ],
      ),
    );
  }
}
